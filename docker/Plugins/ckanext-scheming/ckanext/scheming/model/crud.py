

from ckan.model import Session

from ckanext.scheming.model.dataset_service import Dataset_Service, dataset_service_table


class Dataset_ServiceQuery:
    # convenience properties
    m = Dataset_Service
    cols = [c.name for c in dataset_service_table.c]

    @classmethod
    def create(cls, dataset_id, service_id):
        '''
        Create a new record in the Dataset_Service table.
        :param dataset_id: the id of the dataset served by the Data Service
        :param service_id: the id of the package (type=service) serving the dataset
        :return: the newly created record object
        '''
        new_record = Dataset_Service(dataset_id=dataset_id, service_id=service_id)
        Session.add(new_record)
        Session.commit()
        return new_record

    @classmethod
    def delete_service(cls, service_id):
        '''
        Delete all registry for the service in the dataset-service relationship
        table.
        '''
        to_delete = Session.query(Dataset_Service).filter(Dataset_Service.service_id == service_id)
        ds_count = to_delete.count()
        if ds_count > 0:
            to_delete.delete(synchronize_session=False)
            Session.commit()

    @classmethod
    def delete_dataset(cls, dataset_id):
        '''
        Delete all registry for the dataset in the dataset-service relationship
        table.
        '''
        to_delete = Session.query(Dataset_Service).filter(Dataset_Service.dataset_id == dataset_id)
        ds_count = to_delete.count()
        if ds_count > 0:
            to_delete.delete(synchronize_session=False)
            Session.commit()

    @classmethod
    def read_datasets_for_service(cls, service_id):
        '''
         Retrieve datasets records for the given service.
         :param service_id: the Service id string
         :return: the list of datasets ids
        '''
        result = Session.query(Dataset_Service.dataset_id).filter(Dataset_Service.service_id == service_id).all()
        res = []
        for ds in result:
            res.append(ds[0])
        return res

    @classmethod
    def read_services_for_dataset(cls, dataset_id):
        '''
         Retrieve services records for the given dataset.
         :param dataset_id: the Service id string
         :return: the list of services ids
        '''
        result = Session.query(Dataset_Service.service_id).filter(Dataset_Service.dataset_id == dataset_id).all()
        res = []
        for ds in result:
            res.append(ds[0])
        return res
