"""Tests for validators.py."""

import pytest

import ckan.plugins.toolkit as tk

from ckanext.gitimport.logic import validators


def test_gitimport_reauired_with_valid_value():
    assert validators.gitimport_required("value") == "value"


def test_gitimport_reauired_with_invalid_value():
    with pytest.raises(tk.Invalid):
        validators.gitimport_required(None)
