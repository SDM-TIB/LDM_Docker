# pytest --ckan-ini=test.ini ckanext/jupyternotebook/tests -s
import os
from ckanext.jupyternotebook.JNFile import JNFile

url = "https://raw.githubusercontent.com/guillermobet/files/master/Example%20Machine%20Learning%20Notebook.ipynb"

def test_init():

    try:
        os.mkdir("./test_JN", mode=0o777)
    except:
        pass
    try:
        os.remove("./test_JN/id_date.ipynb")
    except:
        pass


    file = JNFile(url, "id", "date", "./test_JN", "jn_url", testing=True)
    assert file.resource_url == url
    assert file.resource_id == "id"
    assert file.resource_date == "date"
    assert file.filepath == "./test_JN"
    assert file.urlbase == "jn_url"


def test_get_valid_filename():
    file = JNFile(url, "id", "date", "./test_JN", "jn_url", testing=True)
    str = "File!name?"
    res = file.get_valid_filename(str)
    assert "filename" == res

def test_generate_filename():
    file = JNFile(url, "id", "date", "./test_JN", "jn_url", testing=True)
    file.generate_filename()
    assert "id_date.ipynb" == file.filename
    assert "./test_JN/id_date.ipynb" == file.filefullpath

def test_get_notebooks_file():
    # Test not existing file
    file = JNFile("http://url.txt", "id", "date", "./test_JN", "jn_url", testing=True)
    file.get_notebooks_file()
    assert "ERROR" == file.filefullpath

    # Test existing file
    os.chmod("./test_JN", 0o755)
    os.remove("./test_JN/id_date.ipynb")
    os.chmod("./test_JN", 0o555)
    file2 = JNFile(url, "id", "date", "./test_JN", "jn_url", testing=True)

    assert "./test_JN/id_date.ipynb" == file2.filefullpath

def test_file_exists():
    # Test existing file
    file = JNFile("url", "id", "date", "./test_JN", "jn_url", testing=True)
    res = file.file_exists()
    print("FILE", file.filefullpath)
    assert res
    # Test NOT existing file
    file = JNFile("url", "id", "date2", "./test_JN", "jn_url", testing=True)
    res = file.file_exists()
    assert not res


