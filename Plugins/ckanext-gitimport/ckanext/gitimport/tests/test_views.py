"""Tests for views.py."""

import pytest

import ckanext.gitimport.validators as validators


import ckan.plugins.toolkit as tk


@pytest.mark.ckan_config("ckan.plugins", "gitimport")
@pytest.mark.usefixtures("with_plugins")
def test_gitimport_blueprint(app, reset_db):
    resp = app.get(tk.h.url_for("gitimport.page"))
    assert resp.status_code == 200
    assert resp.body == "Hello, gitimport!"
