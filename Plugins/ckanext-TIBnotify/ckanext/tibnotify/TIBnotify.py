import smtplib, os
from os.path import basename
from crontab import CronTab

from ckan.common import config
from ckan.common import _
import ckan.common
import ckan.lib.base as base

import socket
from time import time

from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication
from email.mime.text import MIMEText
from email.header import Header
from email import utils

import logging

log = logging.getLogger(__name__)


class MailerException(Exception):
    pass


class LDM_Notify:

    def __init__(self):
        # CKAN config
        self.ckan_mail_from = config.get('smtp.mail_from', 'Sender not specified')
        self.ckan_reply_to = config.get('smtp.reply_to', 'not@defined.email')

        # TIBnotify config
        self.TIBnotify_sysamdin_name = config.get('TIBnotify.sysadmin_name', 'LDM-Sysadmin')
        self.TIBnotify_sysamdin_email = config.get('TIBnotify.sysadmin_email', 'mauricio.brunet@tib.eu')
        self.TIBnotify_mail_from_name = config.get('TIBnotify.mail_from', 'LDM')
        self.TIBnotify_mail_to = config.get('TIBnotify.mail_to', 'notifications@LDM')

    # CKAN NOTIFICATION SYSTEM
    # https://docs.ckan.org/en/2.9/maintaining/email-notifications.html#email-notifications
    # *******************************

    def enable_ckan_notification_system(self):

        self.ckan_notifications_enabled = ckan.common.asbool(
            config.get('ckan.activity_streams_email_notifications', False))
        self.config_cronjobs()
        if self.ckan_notifications_enabled:
            self.create_cronjobs()
        else:
            self.clean_cronjobs()

    def config_cronjobs(self):
        # ┌───────────── minute(0 - 59)
        # │ ┌───────────── hour(0 - 23)
        # │ │ ┌───────────── day of month(1 - 31)
        # │ │ │ ┌───────────── month(1 - 12)
        # │ │ │ │ ┌───────────── day of week(0 - 6)(Sunday to Saturday;
        # │ │ │ │ │                                       7 is also Sunday on some systems)
        # │ │ │ │ │
        # │ │ │ │ │
        # * * * * *command to execute
        # * any value
        # , value list separator
        # -    range of values
        # / step values Ex: */10 each 10
        # job.setall('2 10 * * *')  10:02 every day
        # list in console: crontab -l

        # config crontab
        self.crontab_user = config.get('TIBnotify.ckan_notifications_crontab_user', "root")
        self.ckan_ini_path = '/etc/ckan/default/ckan.ini'
        self.root_path = '/usr/lib/ckan/default/src/ckanext-TIBnotify/ckanext/tibnotify/'
        self.background_jobs = {
            'ckan_emails':
                {'title': 'update_datasets_luh',
                 'comment': "LDM_check_ckan_notifications",
                 'crontab_commands': [".setall('0 * * * *')"]}
        }

    def get_background_jobs(self):
        return self.background_jobs

    def clean_cronjobs(self):
        cron = CronTab(user=self.crontab_user)
        for job in cron.find_comment('LDM_check_ckan_notifications'):
            cron.remove(job)
        cron.write()

    def create_cronjobs(self):

        cron = CronTab(user=self.crontab_user)
        self.clean_cronjobs()

        if self.ckan_notifications_enabled:

            # Define cronjobs
            for key, cronjob in self.background_jobs.items():

                command = 'ckan post -c ' + self.ckan_ini_path + '/api/action/send_email_notifications > /dev/null'
                job = cron.new(command=command, comment="LDM_check_ckan_notifications")
                for c in cronjob['crontab_commands']:
                    eval('job' + c)

        cron.write()

    def send_importation_update_notification(self, summary):

        subject = "Importation Update - " + summary.get('Repository_name', 'Not Found')
        body_html = base.render(
            'emails/importation_update_notification.html',
            extra_vars={'summary': summary})

        attachments = [summary.get('LOG_file', '')]

        self._send_system_notification_email(subject, 'None', attachments, body_html)

    def _send_system_notification_email(self, subject, body, attachments=None, body_html=None, headers=None):

        # Email data
        sender_name = self.TIBnotify_sysamdin_name
        sender_email = self.TIBnotify_sysamdin_email
        recipient_name = self.TIBnotify_sysamdin_name
        recipient_email = self.TIBnotify_mail_to
        reply_to = ''

        self._send_email(recipient_name, recipient_email, sender_name, sender_email, subject, reply_to,
                         body, body_html, headers, attachments)

    def _set_email_body(self, body, body_html):
        if body_html:
            # multipart
            msg = MIMEMultipart('alternative')
            part1 = MIMEText(body.encode('utf-8'), 'plain', 'utf-8')
            part2 = MIMEText(body_html.encode('utf-8'), 'html', 'utf-8')
            msg.attach(part1)
            msg.attach(part2)
        else:
            # just plain text
            msg = MIMEText(body.encode('utf-8'), 'plain', 'utf-8')
        return msg

    def _set_email_headers(self, headers, msg):
        if not headers:
            headers = {}
        for k, v in headers.items():
            if k in msg.keys():
                msg.replace_header(k, v)
            else:
                msg.add_header(k, v)
        return msg

    def _set_attachments(self, attachments, msg):
        for f in attachments or []:
            with open(f, "rb") as fil:
                part = MIMEApplication(
                    fil.read(),
                    Name=basename(f)
                )
            # After the file is closed
            part['Content-Disposition'] = 'attachment; filename="%s"' % basename(f)
            msg.attach(part)

        return msg

    def _smtp_send_email(self, mail_from, recipient_email, msg):
        # Send the email using Python's smtplib.
        if 'smtp.test_server' in config:
            # If 'smtp.test_server' is configured we assume we're running tests,
            # and don't use the smtp.server, starttls, user, password etc. options.
            smtp_server = config['smtp.test_server']
            smtp_starttls = False
            smtp_user = None
            smtp_password = None
        else:
            smtp_server = config.get('smtp.server', 'localhost')
            smtp_starttls = ckan.common.asbool(config.get('smtp.starttls'))
            smtp_ssl = ckan.common.asbool(config.get('smtp.ssl', False))
            smtp_user = config.get('smtp.user')
            smtp_password = config.get('smtp.password')
            smtp_port = config.get('smtp.port', 25)

        try:
            if smtp_ssl:
                smtp_connection = smtplib.SMTP_SSL(smtp_server, smtp_port)
            else:
                smtp_connection = smtplib.SMTP(smtp_server, smtp_port)
        except (socket.error, smtplib.SMTPConnectError) as e:
            log.exception(e)
            raise MailerException('SMTP server could not be connected to: "%s" %s'
                                  % (smtp_server, e))

        try:
            # Identify ourselves and prompt the server for supported features.
            smtp_connection.ehlo()

            # If 'smtp.starttls' is on in CKAN config, try to put the SMTP
            # connection into TLS mode.
            if smtp_starttls:
                if smtp_connection.has_extn('STARTTLS'):
                    smtp_connection.starttls()
                    # Re-identify ourselves over TLS connection.
                    smtp_connection.ehlo()
                else:
                    raise MailerException("SMTP server does not support STARTTLS")

            # If 'smtp.user' is in CKAN config, try to login to SMTP server.
            if smtp_user:
                assert smtp_password, ("If smtp.user is configured then "
                                       "smtp.password must be configured as well.")
                smtp_connection.login(smtp_user, smtp_password)

            smtp_connection.sendmail(mail_from, [recipient_email], msg.as_string())
            log.info("Sent email to {0}".format(recipient_email))

        except smtplib.SMTPException as e:
            msg = '%r' % e
            log.exception(msg)
            raise MailerException(msg)
        finally:
            smtp_connection.quit()

    def _send_email(self, recipient_name, recipient_email,
                    sender_name, sender_email, subject, reply_to,
                    body, body_html=None, headers=None, attachments=None):

        # set email body
        msg = self._set_email_body(body, body_html)
        # set email headers
        msg = self._set_email_headers(headers, msg)

        # set others
        subject = Header(subject.encode('utf-8'), 'utf-8')
        msg['Subject'] = subject
        msg['From'] = _("%s <%s>") % (sender_name, sender_email)
        msg['To'] = u"%s <%s>" % (recipient_name, recipient_email)
        msg['Date'] = utils.formatdate(time())

        if reply_to and reply_to != '':
            msg['Reply-to'] = reply_to

        # set attachmets
        msg = self._set_attachments(attachments, msg)
        # send email
        self._smtp_send_email(sender_email, recipient_email, msg)

#
#
# def _mail_recipient(recipient_name, recipient_email,
#                     sender_name, sender_url, subject,
#                     body, body_html=None, headers=None):
#
#     if not headers:
#         headers = {}
#
#     mail_from = config.get('smtp.mail_from')
#     reply_to = config.get('smtp.reply_to')
#     if body_html:
#         # multipart
#         msg = MIMEMultipart('alternative')
#         part1 = MIMEText(body.encode('utf-8'), 'plain', 'utf-8')
#         part2 = MIMEText(body_html.encode('utf-8'), 'html', 'utf-8')
#         msg.attach(part1)
#         msg.attach(part2)
#     else:
#         # just plain text
#         msg = MIMEText(body.encode('utf-8'), 'plain', 'utf-8')
#     for k, v in headers.items():
#         if k in msg.keys():
#             msg.replace_header(k, v)
#         else:
#             msg.add_header(k, v)
#     subject = Header(subject.encode('utf-8'), 'utf-8')
#     msg['Subject'] = subject
#     msg['From'] = _("%s <%s>") % (sender_name, mail_from)
#     msg['To'] = u"%s <%s>" % (recipient_name, recipient_email)
#     msg['Date'] = utils.formatdate(time())
#     msg['X-Mailer'] = "CKAN %s" % ckan.__version__
#     if reply_to and reply_to != '':
#         msg['Reply-to'] = reply_to
#
#     # Send the email using Python's smtplib.
#     if 'smtp.test_server' in config:
#         # If 'smtp.test_server' is configured we assume we're running tests,
#         # and don't use the smtp.server, starttls, user, password etc. options.
#         smtp_server = config['smtp.test_server']
#         smtp_starttls = False
#         smtp_user = None
#         smtp_password = None
#     else:
#         smtp_server = config.get('smtp.server', 'localhost')
#         smtp_starttls = ckan.common.asbool(
#             config.get('smtp.starttls'))
#         smtp_user = config.get('smtp.user')
#         smtp_password = config.get('smtp.password')
#
#     try:
#         smtp_connection = smtplib.SMTP(smtp_server)
#     except (socket.error, smtplib.SMTPConnectError) as e:
#         log.exception(e)
#         raise MailerException('SMTP server could not be connected to: "%s" %s'
#                               % (smtp_server, e))
#
#     try:
#         # Identify ourselves and prompt the server for supported features.
#         smtp_connection.ehlo()
#
#         # If 'smtp.starttls' is on in CKAN config, try to put the SMTP
#         # connection into TLS mode.
#         if smtp_starttls:
#             if smtp_connection.has_extn('STARTTLS'):
#                 smtp_connection.starttls()
#                 # Re-identify ourselves over TLS connection.
#                 smtp_connection.ehlo()
#             else:
#                 raise MailerException("SMTP server does not support STARTTLS")
#
#         # If 'smtp.user' is in CKAN config, try to login to SMTP server.
#         if smtp_user:
#             assert smtp_password, ("If smtp.user is configured then "
#                                    "smtp.password must be configured as well.")
#             smtp_connection.login(smtp_user, smtp_password)
#
#         smtp_connection.sendmail(mail_from, [recipient_email], msg.as_string())
#         log.info("Sent email to {0}".format(recipient_email))
#
#     except smtplib.SMTPException as e:
#         msg = '%r' % e
#         log.exception(msg)
#         raise MailerException(msg)
#     finally:
#         smtp_connection.quit()
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# ######### Setup your stuff here #######################################
#
# attachments = ['test_pdf.pdf', 'test_waiver.pdf']
#
# username = 'joe@gmail.com'
# password = 'j0ej0e'
# host = 'smtp.gmail.com:587' # specify port, if required, using this notations
#
# fromaddr = 'joe@rogers.com' # must be a vaild 'from' address in your GApps account
# toaddr  = 'joe@gmail.com'
# replyto = fromaddr # unless you want a different reply-to
#
# msgsubject = 'This is the subject of the email! WooHoo!'
#
# htmlmsgtext = """<h2>This is my message body in HTML...WOW!!!!!</h2>
#                 <p>\
#                  Hey, Hey, Ho, Ho, got a paragraph here. A lovely paragraph it is.\
#                  You've never seen a better paragraph than this.\
#                  I make some of the best paragraphs you have ever seen.\
#                  Hey, Hey, Ho, Ho, got a paragraph here. A lovely paragraph it is.\
#                  You've never seen a better paragraph than this.\
#                  I make some of the best paragraphs you have ever seen.\
#                  </p>
#                 <ul>
#                     <li>This is a list item</li>
#                     <li>This is another list item</li>
#                     <li>And yet another list item, pretty big list</li>
#                     <li>OMG this is a long list!</li>
#                 </ul>
#                 <p><strong>Here are your attachments:</strong></p><br />"""
#
# ######### In normal use nothing changes below this line ###############
#
# # import smtplib, os, sys
# # from email.MIMEMultipart import MIMEMultipart
# # from email.MIMEBase import MIMEBase
# # from email.MIMEText import MIMEText
# # from email import Encoders
# # from HTMLParser import HTMLParser
#
# # A snippet - class to strip HTML tags for the text version of the email
#
# class MLStripper(HTMLParser):
#     def __init__(self):
#         self.reset()
#         self.fed = []
#     def handle_data(self, d):
#         self.fed.append(d)
#     def get_data(self):
#         return ''.join(self.fed)
#
# def strip_tags(html):
#     s = MLStripper()
#     s.feed(html)
#     return s.get_data()
#
# ########################################################################
#
# try:
#     # Make text version from HTML - First convert tags that produce a line break to carriage returns
#     msgtext = htmlmsgtext.replace('</br>',"\r").replace('<br />',"\r").replace('</p>',"\r")
#     # Then strip all the other tags out
#     msgtext = strip_tags(msgtext)
#
#     # necessary mimey stuff
#     msg = MIMEMultipart()
#     msg.preamble = 'This is a multi-part message in MIME format.\n'
#     msg.epilogue = ''
#
#     body = MIMEMultipart('alternative')
#     body.attach(MIMEText(msgtext))
#     body.attach(MIMEText(htmlmsgtext, 'html'))
#     msg.attach(body)
#
#     if 'attachments' in globals() and len('attachments') > 0: # are there attachments?
#         for filename in attachments:
#             f = filename
#             part = MIMEBase('application', "octet-stream")
#             part.set_payload( open(f,"rb").read() )
#             Encoders.encode_base64(part)
#             part.add_header('Content-Disposition', 'attachment; filename="%s"' % os.path.basename(f))
#             msg.attach(part)
#
#     msg.add_header('From', fromaddr)
#     msg.add_header('To', toaddr)
#     msg.add_header('Subject', msgsubject)
#     msg.add_header('Reply-To', replyto)
#
#     # The actual email sendy bits
#     server = smtplib.SMTP(host)
#     server.set_debuglevel(False) # set to True for verbose output
#     try:
#         # gmail expect tls
#         server.starttls()
#         server.login(username,password)
#         server.sendmail(msg['From'], [msg['To']], msg.as_string())
#         print 'Email sent'
#         server.quit() # bye bye
#     except:
#         # if tls is set for non-tls servers you would have raised an exception, so....
#         server.login(username,password)
#         server.sendmail(msg['From'], [msg['To']], msg.as_string())
#         print 'Email sent'
#         server.quit() # sbye bye
# except:
#     print ('Email NOT sent to %s successfully. %s ERR: %s %s %s ', str(toaddr), 'tete', str(sys.exc_info()[0]), str(sys.exc_info()[1]), str(sys.exc_info()[2]) )
#     #just in case
