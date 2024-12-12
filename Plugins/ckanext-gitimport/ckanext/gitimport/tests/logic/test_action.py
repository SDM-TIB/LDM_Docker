"""Tests for action.py."""

import pytest

import ckan.tests.helpers as test_helpers


@pytest.mark.ckan_config("ckan.plugins", "gitimport")
@pytest.mark.usefixtures("with_plugins")
def test_gitimport_get_sum():
    result = test_helpers.call_action(
        "gitimport_get_sum", left=10, right=30)
    assert result["sum"] == 40
