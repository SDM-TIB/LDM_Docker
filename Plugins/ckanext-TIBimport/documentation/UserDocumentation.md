# ckanext-TIBimport – User Documentation

**Version:** v1.0  
**Author:** Mauricio Brunet (mauricio.brunet@tib.eu)  
**Date:** August 15, 2025

## 1. Introduction

### Overview
The ckanext-TIBimport plugin is a powerful CKAN extension that enables automatic importing and synchronization of research datasets from multiple external scientific repositories. This plugin creates "virtual datasets" in your CKAN instance that maintain links to their original sources while providing unified search and discovery capabilities.

The plugin is designed for research institutions, libraries, and data portals that need to aggregate and provide access to datasets from various scientific repositories without duplicating the actual data files.

### Key Features
- **Multi-Repository Support**: Import from 7+ major scientific repositories including PANGAEA, LEUPHANA, LEOPARD, RADAR, and others
- **Automated Synchronization**: Schedule regular updates to keep imported datasets current
- **Virtual Dataset Management**: Create lightweight dataset records that link to original sources
- **Metadata Transformation**: Automatically convert repository-specific metadata to CKAN's standard schema
- **DOI Integration**: Handle DOI resolution and validation for research datasets
- **Background Processing**: Non-blocking import operations that don't interfere with normal CKAN usage
- **Comprehensive Logging**: Detailed import reports and error tracking
- **Flexible Configuration**: Customizable import schedules and repository-specific settings

## 2. Installation

### System Requirements

#### Hardware Requirements
- **Minimum**: 2 CPU cores, 4GB RAM, 10GB available storage
- **Recommended**: 4+ CPU cores, 8GB+ RAM, 50GB+ available storage
- **Network**: Stable internet connection for accessing external repositories

#### Software Dependencies
- **Operating System**: Linux (Ubuntu 18.04+ recommended)
- **Python**: Version 3.7 or higher
- **CKAN**: Version 2.9 or higher
- **Database**: PostgreSQL 10+
- **Web Server**: Apache or Nginx
- **Additional Python Packages**: Automatically installed with the plugin

### Installation Steps

#### Method 1: Standard Installation (Recommended)

1. **Activate your CKAN virtual environment**
   ```bash
   . /usr/lib/ckan/default/bin/activate
   ```

2. copy the ckanext-TIBimport folder to /usr/lib/ckan/default/src/ and cd to the src folder

3. **Install the plugin**
   ```bash
   pip install -e ckanext-TIBimport
   ```

4. **Add the plugin to your CKAN configuration**
   
   Edit your CKAN configuration file (typically `/etc/ckan/default/ckan.ini`):
   ```ini
   ckan.plugins = datastore datapusher ... tibimport
   ```

5. **Restart your CKAN services**
   ```bash
   sudo service apache2 reload
   # or for nginx:
   sudo service nginx reload
   ```

#### Method 2: Development Installation

1. copy the ckanext-TIBimport folder to /usr/lib/ckan/default/src/ and cd to the src folder

2. **Install in development mode**
   ```bash
   . /usr/lib/ckan/default/bin/activate
   python setup.py develop
   pip install -r dev-requirements.txt
   ```

3. **Configure and restart as above**

#### Verification
To verify the installation was successful:
1. Check that no errors appear in your CKAN logs
2. Test access to import URLs (admin users only)

## 3. Getting Started

### Launching the Plugin

The plugin integrates seamlessly with CKAN and provides several ways to access its functionality:

#### Web Interface Access
1. **Log in as a system administrator** to your CKAN instance
2. **Navigate to import URLs** (these are admin-only endpoints):
   - `/import_vdatasets_luh` - Import from Leibniz University Hannover
   - `/import_vdatasets_png/agriculture` - Import PANGAEA agriculture datasets
   - `/import_vdatasets_rdr` - Import from RADAR repository
   - `/import_vdatasets_leo` - Import from LEOPARD repository
   - And more...

#### Background Job Interface
1. **Access the job management system** through CKAN's admin interface
2. **Schedule automated imports** using the background job URLs:
   - `/tib_add_imported_datasets_update/luh`
   - `/tib_add_imported_datasets_update/radar`
   - etc.

### Basic Configuration

#### Essential Configuration Options

Add these settings to your CKAN configuration file (`/etc/ckan/default/ckan.ini`):

```ini
# Enable the plugin
ckan.plugins = ... tibimport

# Configure log file location (optional)
tibimport.log_file_path = /var/log/ckan/tibimport/

# Configure automatic updates
tibimport.updatedatasets_enabled = true
tibimport.updatedatasets_crontab_user = ckan

```

#### Directory Setup
Ensure the log directory exists and is writable:
```bash
sudo mkdir -p /var/log/ckan/tibimport/
sudo chown ckan:ckan /var/log/ckan/tibimport/
```

## 4. Usage Guide

### Main Functions

#### 1. Manual Dataset Import

**Purpose**: Import datasets immediately from a specific repository

**Steps**:
1. **Access the import URL** for your desired repository:
   ```
   https://your-ckan-site.com/import_vdatasets_luh
   ```
2. **Wait for the process to complete** - you'll see a summary page
3. **Review the import results** showing:
   - Number of datasets inserted
   - Number of datasets updated
   - Number of datasets skipped
   - Link to detailed log file

**Example Result Page**:
```
Repository: Leibniz University Hannover
Datasets inserted: 45
Datasets updated: 12
Datasets skipped: 203
Log file: /var/log/ckan/tibimport/LUH_2025_01_30_log.log
```

#### 2. PANGAEA Topic-Specific Import

**Purpose**: Import datasets from PANGAEA by scientific topic

**Steps**:
1. **Choose a topic** from the available options:
   - `agriculture` - Agricultural sciences
   - `chemistry` - Chemical sciences
   - `atmosphere` - Atmospheric sciences
   - `oceans` - Ocean sciences
   - `ecology` - Ecological sciences
   - And more...

2. **Access the topic-specific URL**:
   ```
   https://your-ckan-site.com/import_vdatasets_png/chemistry
   ```

3. **Monitor the import progress** through the result page

#### 3. Scheduled Background Imports

**Purpose**: Set up automatic, recurring imports

**Steps**:
1. **Scheduled imports are defined as crontab jobs in the server and can be viewed and changed in ckanex/logic2.py**:
   ```
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

        self.background_jobs = {
                   'luh':
                       {'title': 'update_datasets_luh',
                        'method': 'TIB_update_imported_datasets_luh',
                        'comment': "TIB_update_imported_datasets_luh",
                        'crontab_commands': [".setall('0 0 2 * *')"]},
                   'radar':
                       {'title': 'update_datasets_radar',
                        'method': 'TIB_update_imported_datasets_radar',
                        'comment': "TIB_update_imported_datasets_radar",
                        'crontab_commands': [".setall('0 0 3 * *')"]},

   continues...
   ```

2. **Schedule an import** by accessing:
   ```
   https://your-ckan-site.com/tib_add_imported_datasets_update/luh
   ```

3. **Verify the job was queued** - you'll see a confirmation message

**Default Schedule**:
- LUH: 2nd of each month at midnight
- RADAR: 3rd of each month at midnight
- PANGAEA topics: 4th-7th of each month at various hours
- LEOPARD: 6th of each month at 3 AM
- And more...

#### 4. Viewing Imported Datasets

**Steps**:
1. **Navigate to your CKAN dataset list**
2. **Filter by dataset type**: Look for datasets marked as "vdataset"
3. **Identify source repositories**: Check the "Repository" field
4. **Access original sources**: Click the provided URLs to view datasets in their original repositories

### Examples and Use Cases

#### Use Case 1: Research Institution Data Portal

**Scenario**: A university wants to showcase all research datasets produced by their faculty across multiple repositories.

**Solution**:
1. Configure imports from relevant repositories (LUH, LEUPHANA, etc.)
2. Set up weekly automated synchronization
3. Customize organization display to highlight university affiliation
4. Enable virtual dataset ribbons to clearly identify external sources

#### Use Case 2: Subject-Specific Data Discovery

**Scenario**: An environmental science portal wants to aggregate datasets from multiple sources.

**Solution**:
1. Import PANGAEA datasets by relevant topics (atmosphere, oceans, ecology)
2. Import from RADAR and other environmental repositories
3. Use CKAN's search and filtering to create subject-specific views
4. Set up automated updates to capture new environmental datasets

#### Use Case 3: Compliance and Reporting

**Scenario**: An institution needs to track and report on all datasets with DOIs produced by their researchers.

**Solution**:
1. Import from all relevant repositories
2. Use the DOI fields in imported datasets for tracking
3. Generate reports using CKAN's API
4. Monitor import logs for data quality and completeness

### Advanced Configuration Examples

#### Custom Log Location
```ini
# Store logs in a custom directory
tibimport.log_file_path = /home/ckan/custom-logs/tibimport/
```

#### PANGAEA Resumption Token Recovery
```ini
# Resume interrupted PANGAEA imports
force_resumption_token_pangaea = true
resumption_token_pangaea = "your-resumption-token-here"
```

#### Cron User Configuration
```ini
# Use a specific user for cron jobs
tibimport.updatedatasets_crontab_user = root
```

## 5. Troubleshooting

### Common Issues

#### Issue 1: Import Process Hangs or Times Out

**Symptoms**:
- Import page loads indefinitely
- No datasets are imported after long wait times
- Server becomes unresponsive

**Solutions**:
1. **Check network connectivity**:
   ```bash
   curl -I https://ws.pangaea.de/oai/provider
   ```

2. **Review server resources**:
   ```bash
   top
   df -h
   ```

3. **Check CKAN logs**:
   ```bash
   tail -f /var/log/ckan/default/ckan.log
   ```

4. **Use background jobs instead** of direct imports for large repositories

#### Issue 2: "Permission Denied" Errors

**Symptoms**:
- HTTP 403 errors when accessing import URLs
- "Access denied" messages

**Solutions**:
1. **Verify admin privileges**:
   - Ensure you're logged in as a system administrator
   - Check user permissions in CKAN admin panel

2. **Check CKAN configuration**:
   ```ini
   ckan.auth.create_dataset_if_not_in_organization = true
   ```

#### Issue 3: Datasets Not Appearing After Import

**Symptoms**:
- Import reports success but no new datasets visible
- Dataset count doesn't increase

**Solutions**:
1. **Rebuild search index**:
   ```bash
   ckan search-index rebuild
   ```

2. **Check dataset visibility**:
   - Verify datasets aren't marked as private
   - Check organization membership

3. **Review import logs** for filtering criteria that might exclude datasets


### Support Resources

#### Log File Analysis
Import logs contain detailed information about each operation:
```bash
# View recent import activity
tail -100 /var/log/ckan/tibimport/LUH_2025_01_30_log.log

# Search for errors
grep -i error /var/log/ckan/tibimport/*.log

# Monitor real-time import activity
tail -f /var/log/ckan/tibimport/*.log
```

#### Configuration Validation
```bash
# Test CKAN configuration
ckan config-tool /etc/ckan/default/ckan.ini -f

# Verify plugin loading
ckan --plugin=tibimport --help
```

## 6. FAQs

### General Questions

**Q: What types of datasets can be imported?**
A: The plugin imports metadata for research datasets from scientific repositories. It creates "virtual datasets" that link to the original data sources rather than copying the actual data files.

**Q: How often should I run imports?**
A: This depends on how frequently the source repositories update their content. Monthly imports are typically sufficient for most repositories, but you can adjust based on your needs.

**Q: Can I customize which datasets are imported?**
A: Yes, each repository parser includes filtering logic. For example, LEUPHANA only imports datasets (not other publication types) and only open-access datasets.

**Q: What happens if an import fails?**
A: Failed imports are logged with detailed error messages. The system will skip problematic datasets and continue processing others. You can review logs to identify and resolve issues.

## 7. Appendices

### Glossary

**Virtual Dataset (vdataset)**: A CKAN dataset record that contains metadata about a dataset stored in an external repository, with links to the original source.

**Parser Profile**: A Python class that handles repository-specific data extraction and transformation logic.

**OAI-PMH**: Open Archives Initiative Protocol for Metadata Harvesting - a standard protocol for metadata exchange.

**DOI**: Digital Object Identifier - a persistent identifier for digital objects, commonly used for research datasets.

**Resumption Token**: A mechanism used by OAI-PMH to handle large result sets by providing pagination.

**Background Job**: An asynchronous task that runs independently of web requests, used for long-running import operations.

### References

#### External Documentation
- [CKAN Extension Development Guide](https://docs.ckan.org/en/latest/extensions/)
- [OAI-PMH Protocol Specification](https://www.openarchives.org/OAI/openarchivesprotocol.html)
- [DataCite Metadata Schema](https://schema.datacite.org/)

#### Repository APIs
- [PANGAEA OAI-PMH](https://ws.pangaea.de/oai/)
- [LEUPHANA Repository](https://pubdata.leuphana.de/oai)
- [RADAR Repository](https://www.radar-service.eu/)

#### Support Channels

- **Primary Contact**: mauricio.brunet@tib.eu
- **CKAN Community**: https://github.com/ckan/ckan/discussions

### Configuration Reference

#### Complete Configuration Example
```ini
# Plugin activation
ckan.plugins = datastore datapusher resource_proxy text_view image_view recline_view tibimport

# TIBimport-specific settings
tibimport.log_file_path = /var/log/ckan/tibimport/
tibimport.updatedatasets_enabled = true
tibimport.updatedatasets_crontab_user = ckan

# Optional PANGAEA settings
force_resumption_token_pangaea = false
resumption_token_pangaea = ""

# CKAN settings that affect imports
ckan.auth.create_dataset_if_not_in_organization = true
ckan.auth.user_create_organizations = false
ckan.auth.user_create_groups = false
```

#### Supported Repository Endpoints
| Repository | Import URL | Background Job URL |
|------------|------------|-------------------|
| LUH | `/import_vdatasets_luh` | `/tib_add_imported_datasets_update/luh` |
| RADAR | `/import_vdatasets_rdr` | `/tib_add_imported_datasets_update/radar` |
| LEOPARD | `/import_vdatasets_leo` | `/tib_add_imported_datasets_update/leopard` |
| OSNADATA | `/import_vdatasets_osn` | `/tib_add_imported_datasets_update/osnadata` |
| GOETTINGEN | `/import_vdatasets_goe` | `/tib_add_imported_datasets_update/goettingen` |
| LEUPHANA | `/import_vdatasets_leu` | `/tib_add_imported_datasets_update/leuphana` |
| PANGAEA | `/import_vdatasets_png/<topic>` | `/tib_add_imported_datasets_update/pangea_<topic>` |
