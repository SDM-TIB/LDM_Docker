import click


@click.group(short_help="gitimport CLI.")
def gitimport():
    """gitimport CLI.
    """
    pass


@gitimport.command()
@click.argument("name", default="gitimport")
def command(name):
    """Docs.
    """
    click.echo("Hello, {name}!".format(name=name))


def get_commands():
    return [gitimport]
