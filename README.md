# The Leibniz Data Manager (LDM)

The Leibniz Data Manager (LDM) is an open source and free web-based application for Research Data Management (RDM). LDM delivers different distributions to best fit the specific requirements of various customers, e.g., institutes and research groups performing RDM in various scientific disciplines. The LDM distributions are designed, maintained, and curated by  TIB  and  L3S.

The prototype currently offers the following functions for the visualization of research data:

Supports data collections and publications  with different formats
Different views on the same data set (2D and 3D support)
Visualization of Auto CAD files
Jupyter Notes for demonstrating live code
RDF Description of data collections
The file specific viewers were implemented using CKAN (Comprehensive Knowledge Archive Network) plugins to render existing viewers for the datasets included in the CKAN instance.

The RDM arelated concepts, the LDM distributions, and the deployment methods are explained in the projects wiki on GitHub.

Besides the Leibniz Data Manager, TIB provides further services around research data management for institutions and researchers. This includes a DOI service, support in choosing the right repositories, and in publishing and archiving research data, as well as training and advisory services. Please refer to our homepage for a full service description: https://www.tib.eu/en/publishing-archiving/research-data/

More info about the LDM project can be found on the TIB webpage and the last updated code in the GitHub repository.

Please, contact us at service.ldm@tib.eu if you have comments or questions.


# LDM Features

![LDM Architecture](ArchitectureLDM.png)


## Wikidata Explorer Feature
With this feature the user is able to extend CSV datasets with existing information in the Wikidata KG. The tool applies entity linking to all concepts in the same column and enable the user to use the extracted entities to extend the dataset. Here below is a demo video of how the tool works: [Video](https://service.tib.eu/ldmservice/dataset/66e93a29-1dc3-48a3-9611-02c29e221cec/resource/fa0b0487-fee8-43f6-a7bc-23657e8e5f53/download/ldm-falcon.mp4)

## Live Code
This feature enables users to create, share, and execute live code interactively. We use JupyterHub, which allows multiple users to use the Jupyter Notebook and manages a separate Jupyter environment for each user. The feature facilitates exploratory data analysis and visualization of code outputs. Furthermore, it is ideal for teaching and data science. Here below is a demo video of how the tool works: [Video](https://service.tib.eu/ldmservice/dataset/fe99ccfb-f888-40aa-b31c-f855a29159a6/resource/2b6b7e42-035e-4d87-8538-1a5f396d5c74/download/live_code_demo.mp4)


## Federated Search
This feature enables users to execute SPARQL queries over a federation of ORKGs, i.e., retrieving answers from multiple KGs with a single query. DeTrusty decomposes the query and retrieves the answers from the appropriate KGs. The federation includes but is not limited to the LDM KG and the ORKG. Here below is a demo video of how the tool works: [Video](https://service.tib.eu/ldmservice/dataset/f2046c00-836e-487a-b57c-bc892e9368d1/resource/01af5e1c-0eae-45ab-b64d-43812881722e/download/fedorkg.mp4)

## Datasets Comparison
This feature enables users to compare the data of multiple CSV datasets. The feature allows the users to analyze the combined data in a table. Moreover, the feature is capable of producing different plots putting selected attributes into perspective. Here below is a demo video of how the tool works: [Video](https://service.tib.eu/ldmservice/dataset/7fa08901-7fb5-43cc-880f-ccc6b0530aff/resource/2ca58284-3a9c-452f-b505-7952e60fb458/download/datacomparison.mp4)

## Enhancing Links between ORKG KGs
By adding the DOI of the paper that defines the dataset to the LDM, a link to the corresponding paper in the ORKG will added to the dataset. Here below is a demo video of how the tool works: [Video](https://service.tib.eu/ldmservice/dataset/1187f2d4-25cb-45eb-b5bd-01b2957f26b1/resource/30167b3c-a543-4f9c-bea3-67099727ec2d/download/ldm_orkg.mp4)







