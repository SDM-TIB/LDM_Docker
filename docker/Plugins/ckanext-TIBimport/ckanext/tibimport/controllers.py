from ckan.plugins import toolkit

BaseController = toolkit.BaseController

class TIBImportController(BaseController):

    def read_catalog(self, _format=None):
        return "TEST"

    def read_dataset(self, _id, _format=None):
        return "TEST2"
