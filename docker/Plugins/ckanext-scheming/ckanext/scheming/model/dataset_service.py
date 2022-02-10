#!/usr/bin/env python3
# encoding: utf-8


from ckan.model import Package, meta
from ckan.model.domain_object import DomainObject
from sqlalchemy import Column, ForeignKey, Table, types
from sqlalchemy.orm import backref, relation

dataset_service_table = Table(
    'dataset_service',
    meta.metadata,
    Column('dataset_id', types.UnicodeText,
           ForeignKey('package.id', onupdate='CASCADE', ondelete='CASCADE'),
           nullable=False, unique=False, primary_key=True),
    Column('service_id', types.UnicodeText,
           ForeignKey('package.id', onupdate='CASCADE', ondelete='CASCADE'),
           nullable=False, unique=False, primary_key=True),
)


class Dataset_Service(DomainObject):
    '''Dataset Service Object'''
    pass


meta.mapper(Dataset_Service, dataset_service_table, properties={
    'dataset': relation(
        Package,
        backref=backref('dataset_service', cascade='all, delete-orphan'),
        primaryjoin=dataset_service_table.c.dataset_id.__eq__(Package.id)
    ),
    'service': relation(
        Package,
        backref=backref('service_dataset', cascade='all, delete-orphan'),
        primaryjoin=dataset_service_table.c.service_id.__eq__(Package.id)
    )
})
