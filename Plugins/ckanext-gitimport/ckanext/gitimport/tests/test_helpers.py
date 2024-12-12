"""Tests for helpers.py."""

import ckanext.gitimport.helpers as helpers


def test_gitimport_hello():
    assert helpers.gitimport_hello() == "Hello, gitimport!"
