from ckan import model
import ckan.plugins.toolkit as toolkit
import flask
import io
from rdflib import Graph

CONTENT_TYPES = {
    'rdf': 'application/rdf+xml',
    'xml': 'application/rdf+xml',
    'n3': 'text/n3',
    'ttl': 'text/turtle',
    'jsonld': 'application/ld+json',
}

def read_content():
    return """
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/ns/dcat#DataService> .
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/ns/dcat#Dataset> .
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://purl.org/dc/terms/modified> "2025-12-01T16:07:58.688455" .
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://purl.org/dc/terms/creator> <https://research.tib.eu/ldm/20> .
<https://research.tib.eu/ldm/20> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/spar/pro/Author> .
<https://research.tib.eu/ldm/20> <http://www.w3.org/2000/01/rdf-schema#label> "Maria-Esther Vidal" .
<https://research.tib.eu/ldm/20> <http://www.w3.org/2002/07/owl#sameAS> <https://orcid.org/0000-0003-1160-8727> .
<https://research.tib.eu/ldm/20> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> .
<https://research.tib.eu/ldm/20> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/672f2339-c57f-48f5-a681-b62acc50f488> .
<https://research.tib.eu/ldm/20> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/9e7d3aa5-120c-499e-83b9-28c45b79060f> .
<https://research.tib.eu/ldm/20> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/1cb0241c-15d4-4c77-90aa-2207cc05e613> .
<https://research.tib.eu/ldm/20> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/01e4ef01-5ffe-4fe7-9be0-aba08510fc41> .
<https://research.tib.eu/ldm/20> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/1fa427a7-3114-4a48-b633-398413bb921f> .
<https://research.tib.eu/ldm/20> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/25a28ec2-f9a8-412f-a6e8-6808b66ef957> .
<https://research.tib.eu/ldm/20> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/3c9157d0-93d9-4256-909d-f76f52351909> .
<https://research.tib.eu/ldm/20> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/4e81c650-6b82-4a0a-bf3c-ab81394cf8df> .
<https://research.tib.eu/ldm/20> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/5f2180c2-be1d-45c3-a3c3-831f400b2f81> .
<https://research.tib.eu/ldm/20> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/a20fb045-ddac-4463-ae86-10d1df1d5c9e> .
<https://research.tib.eu/ldm/20> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/c22ad20e-d0e3-4be2-8041-ba71bfa29873> .
<https://research.tib.eu/ldm/20> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/e121be86-7419-4b5a-8507-344dd6851d1c> .
<https://research.tib.eu/ldm/20> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/e2d84387-2dfc-43c3-b372-0b23b128a79c> .
<https://research.tib.eu/ldm/20> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/f4ca536c-a868-4596-a2be-235676e7badf> .
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://purl.org/dc/terms/creator> <https://research.tib.eu/ldm/24> .
<https://research.tib.eu/ldm/24> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/spar/pro/Author> .
<https://research.tib.eu/ldm/24> <http://www.w3.org/2000/01/rdf-schema#label> "Yashrajsinh Chudasama" .
<https://research.tib.eu/ldm/24> <http://www.w3.org/2002/07/owl#sameAS> <https://orcid.org/0000-0003-3422-366X> .
<https://research.tib.eu/ldm/24> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> .
<https://research.tib.eu/ldm/24> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/eec82534-2e52-44bc-b559-3f2f44ad4aa9> .
<https://research.tib.eu/ldm/24> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/a20fb045-ddac-4463-ae86-10d1df1d5c9e> .
<https://research.tib.eu/ldm/24> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/e2d84387-2dfc-43c3-b372-0b23b128a79c> .
<https://research.tib.eu/ldm/24> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/f4ca536c-a868-4596-a2be-235676e7badf> .
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://purl.org/dc/terms/creator> <https://research.tib.eu/ldm/25> .
<https://research.tib.eu/ldm/25> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/spar/pro/Author> .
<https://research.tib.eu/ldm/25> <http://www.w3.org/2000/01/rdf-schema#label> "Disha Purohit" .
<https://research.tib.eu/ldm/25> <http://www.w3.org/2002/07/owl#sameAS> <https://orcid.org/0000-0002-1442-335X> .
<https://research.tib.eu/ldm/25> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> .
<https://research.tib.eu/ldm/25> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/eec82534-2e52-44bc-b559-3f2f44ad4aa9> .
<https://research.tib.eu/ldm/25> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/a20fb045-ddac-4463-ae86-10d1df1d5c9e> .
<https://research.tib.eu/ldm/25> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/e2d84387-2dfc-43c3-b372-0b23b128a79c> .
<https://research.tib.eu/ldm/25> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/f4ca536c-a868-4596-a2be-235676e7badf> .
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://purl.org/dc/terms/creator> <https://research.tib.eu/ldm/26> .
<https://research.tib.eu/ldm/26> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/spar/pro/Author> .
<https://research.tib.eu/ldm/26> <http://www.w3.org/2000/01/rdf-schema#label> "Enrique Iglesias" .
<https://research.tib.eu/ldm/26> <http://www.w3.org/2002/07/owl#sameAS> <https://orcid.org/0000-0002-8734-3123> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/09ed4d5d-7fcd-4ce3-9ba5-8cf42d57ee2c> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/21b43f26-5753-4c78-a45a-1b6b4bf2d44b> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/28384b4c-ee8a-4d38-886a-baee369430d9> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/289a72e9-58be-47c1-bbdd-2bf04141c303> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/3701bbed-8683-4ed6-a4e9-1e23b4c6c542> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/3ed950c4-eab3-434a-aec4-ed0d2b9c7e31> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/40375219-aae0-49ac-9ce0-1617d8a3c240> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/4500197b-2fbe-47ee-a24c-73726f0b1815> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/492dc42e-df6c-4cba-bb4c-5562689627e6> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/4a5b1066-7eef-4963-999e-5d8bbdb561e0> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/4ce41b70-6175-428e-b7a4-8c52d6ceda60> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/4d03c927-1877-4459-95a2-4a248e502765> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/4e1596b9-90da-4011-bfeb-51e52c5d27b0> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/4f50fe06-9047-4a92-a953-2ccb04af9bcf> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/5f2180c2-be1d-45c3-a3c3-831f400b2f81> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/608c3c65-fe2d-477d-8fd5-1ec248ae3e5d> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/6509e4fb-6b00-47f4-a2c0-35e8b69f36fb> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/6f0ba6de-7b20-4823-81ff-e35579e1079c> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/78c83ea8-0167-4661-b140-ec23e39735e9> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/7cd16f2d-9570-44c6-888a-5d1f43043c67> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/839f677d-4e97-4f7d-aea1-cb35947368e2> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/86332a2c-6983-4369-90f6-0f503f9544ea> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/9a543389-6c85-4c50-98ec-d199073baf70> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/9ae03d7b-f02d-4df2-bde6-49728e834027> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/a1ae9d8b-eb58-4611-9d4b-59d147299531> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/a40e0cc1-d314-4dcc-9fe2-ac68ff336b7e> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/aaa875cf-d07f-4034-abae-09ba88eca93c> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/b5d19739-bdd3-412b-96cd-4158235b8f09> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/ba139a6a-9cf3-46d5-8a25-b338f90bd1bc> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/ba1ddb9d-631f-463d-a12d-a3762cbee893> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/ce115b9d-870f-436b-a8f7-386a6c65834f> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/ce733a0e-950e-42ac-80f1-bc0ffeae74b9> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/d2e5af1b-4a74-4bba-8199-e6d138e37243> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/d6768440-7bc5-457a-99f0-d0f82ee409cd> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/df5b7113-d32b-40bd-98ed-2ed55843b250> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/e48e0a1a-1771-4832-a83c-b88a5d29b2a4> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/e6e37d74-7cfc-458e-ac29-ed153b414354> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/e8a0620f-63a3-433c-8a85-c1c085159ea2> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/ebd8488f-a92b-46c9-899c-1e0b7f4f01e1> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/f00cdc84-5be1-4d2d-b00c-d8a957d78a0b> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/f43c99b5-4b4b-4df0-8e11-f8e5c75ed1ec> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/f59619c4-ee95-4102-8bc1-8583a82460d4> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/f9a12656-d803-4ef9-848a-784ec3c7d20d> .
<https://research.tib.eu/ldm/26> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/fe742c08-cebc-489a-b205-e7f4a6487829> .
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://purl.org/dc/terms/creator> <https://research.tib.eu/ldm/27> .
<https://research.tib.eu/ldm/27> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/spar/pro/Author> .
<https://research.tib.eu/ldm/27> <http://www.w3.org/2000/01/rdf-schema#label> "Mahsa Forghani" .
<https://research.tib.eu/ldm/27> <http://www.w3.org/2002/07/owl#sameAS> <https://orcid.org/0009-0001-6000-2636> .
<https://research.tib.eu/ldm/27> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> .
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://purl.org/dc/terms/creator> <https://research.tib.eu/ldm/28> .
<https://research.tib.eu/ldm/28> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/spar/pro/Author> .
<https://research.tib.eu/ldm/28> <http://www.w3.org/2000/01/rdf-schema#label> "Johannes E. Bendler" .
<https://research.tib.eu/ldm/28> <http://www.w3.org/2002/07/owl#sameAS> <https://orcid.org/0009-0002-3568-5145> .
<https://research.tib.eu/ldm/28> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> .
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://purl.org/dc/terms/creator> <https://research.tib.eu/ldm/29> .
<https://research.tib.eu/ldm/29> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/spar/pro/Author> .
<https://research.tib.eu/ldm/29> <http://www.w3.org/2000/01/rdf-schema#label> "Annette ten Teije" .
<https://research.tib.eu/ldm/29> <http://www.w3.org/2002/07/owl#sameAS> <https://orcid.org/0000-0002-9771-8822> .
<https://research.tib.eu/ldm/29> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> .
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://purl.org/dc/terms/creator> <https://research.tib.eu/ldm/30> .
<https://research.tib.eu/ldm/30> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/spar/pro/Author> .
<https://research.tib.eu/ldm/30> <http://www.w3.org/2000/01/rdf-schema#label> "Frank van Harmelen" .
<https://research.tib.eu/ldm/30> <http://www.w3.org/2002/07/owl#sameAS> <https://orcid.org/0000-0002-7913-0048> .
<https://research.tib.eu/ldm/30> <http://purl.org/spar/pro/authorOf> <https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> .
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://www.w3.org/ns/dcat#distribution> <https://research.tib.eu/ldm/fc3ff929-5795-4e60-8218-e0c175d0bb4a> .
<https://research.tib.eu/ldm/fc3ff929-5795-4e60-8218-e0c175d0bb4a> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/ns/dcat#Distribution> .
<https://research.tib.eu/ldm/fc3ff929-5795-4e60-8218-e0c175d0bb4a> <http://purl.org/dc/terms/modified> "2025-12-01T16:05:00.375978" .
<https://research.tib.eu/ldm/fc3ff929-5795-4e60-8218-e0c175d0bb4a> <http://purl.org/dc/terms/format> "ipynb" .
<https://research.tib.eu/ldm/fc3ff929-5795-4e60-8218-e0c175d0bb4a> <http://www.w3.org/ns/dcat#accessURL> <https://service.tib.eu/ldmservice/dataset/1e3c4a2d-07cf-40d7-ad13-a577da67cea0/resource/fc3ff929-5795-4e60-8218-e0c175d0bb4a/download/boxology_kg_exploration.ipynb> .
<https://research.tib.eu/ldm/fc3ff929-5795-4e60-8218-e0c175d0bb4a> <http://www.w3.org/ns/dcat#byteSize> "888290" .
<https://research.tib.eu/ldm/fc3ff929-5795-4e60-8218-e0c175d0bb4a> <http://www.w3.org/ns/dcat#downloadURL> <https://service.tib.eu/ldmservice/dataset/1e3c4a2d-07cf-40d7-ad13-a577da67cea0/resource/fc3ff929-5795-4e60-8218-e0c175d0bb4a/download/boxology_kg_exploration.ipynb> .
<https://research.tib.eu/ldm/fc3ff929-5795-4e60-8218-e0c175d0bb4a> <http://purl.org/dc/terms/issued> "2025-12-01T13:17:13.692276" .
<https://research.tib.eu/ldm/fc3ff929-5795-4e60-8218-e0c175d0bb4a> <http://purl.org/dc/terms/title> "T4Boxology KG Exploration and Analysis" .
<https://research.tib.eu/ldm/fc3ff929-5795-4e60-8218-e0c175d0bb4a> <http://purl.org/dc/terms/language> "English" .
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://purl.org/dc/terms/identifier> "1e3c4a2d-07cf-40d7-ad13-a577da67cea0" .
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://purl.org/dc/terms/issued> "2025-12-01T13:15:54.892869" .
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://purl.org/dc/terms/publisher> <https://service.tib.eu/ldmservice/organization/0c5362f5-b99e-41db-8256-3d0d7549bf4d> .
<https://service.tib.eu/ldmservice/organization/0c5362f5-b99e-41db-8256-3d0d7549bf4d> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2006/vcard/ns#Organization> .
<https://service.tib.eu/ldmservice/organization/0c5362f5-b99e-41db-8256-3d0d7549bf4d> <http://www.w3.org/2000/01/rdf-schema#label> "tib" .
<https://service.tib.eu/ldmservice/organization/0c5362f5-b99e-41db-8256-3d0d7549bf4d> <http://www.w3.org/ns/dcat#landingPage> <https://service.tib.eu/ldmservice/organization/tib> .
<https://service.tib.eu/ldmservice/organization/0c5362f5-b99e-41db-8256-3d0d7549bf4d> <http://purl.org/dc/terms/title> "TIB" .
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://purl.org/dc/terms/title> "Tool4Boxology: A Semantic Toolbox for Constructing and Analyzing Neuro-Symbolic Architectures" .
<https://research.tib.eu/ldm/1e3c4a2d-07cf-40d7-ad13-a577da67cea0> <http://www.w3.org/2006/vcard/ns#fn> "Yashrajsinh Chudasama" .
"""

def download_dataset_rdf (_id):
    file_content = read_content()

    g = Graph()
    g.parse(data=file_content, format="n3")
    ttl_data = g.serialize(format="xml")

    file_buffer = io.BytesIO(ttl_data.encode("utf-8"))
    file_buffer.seek(0)

    return flask.send_file(
        file_buffer,
        mimetype=CONTENT_TYPES.get("rdf", "text/plain"),
        as_attachment=False,
        attachment_filename=f"{_id}.rdf"
    )

def download_dataset_xml (_id):
    file_content = read_content()

    g = Graph()
    g.parse(data=file_content, format="n3")
    ttl_data = g.serialize(format="xml")

    file_buffer = io.BytesIO(ttl_data.encode("utf-8"))
    file_buffer.seek(0)

    return flask.send_file(
        file_buffer,
        mimetype=CONTENT_TYPES.get("xml", "text/plain"),
        as_attachment=False,
        attachment_filename=f"{_id}.xml"
    )

def download_dataset_n3 (_id):
    file_content = read_content()

    # convert to bytes
    file_buffer = io.BytesIO(file_content.encode("utf-8"))
    file_buffer.seek(0)

    return flask.send_file(
        file_buffer,
        mimetype=CONTENT_TYPES.get("n3", "text/plain"),
        as_attachment=False,
        attachment_filename=f"{_id}.n3"
    )

def download_dataset_ttl (_id):
    file_content = read_content()

    g = Graph()
    g.parse(data=file_content, format="n3")
    ttl_data = g.serialize(format="ttl")

    file_buffer = io.BytesIO(ttl_data.encode("utf-8"))
    file_buffer.seek(0)

    return flask.send_file(
        file_buffer,
        mimetype=CONTENT_TYPES.get("ttl", "text/plain"),
        as_attachment=False,
        attachment_filename=f"{_id}.ttl"
    )

def download_dataset_jsonld (_id):
    file_content = read_content()

    g = Graph()
    g.parse(data=file_content, format="n3")
    ttl_data = g.serialize(format="json-ld")

    file_buffer = io.BytesIO(ttl_data.encode("utf-8"))
    file_buffer.seek(0)

    return flask.send_file(
        file_buffer,
        mimetype=CONTENT_TYPES.get("jsonld", "text/plain"),
        as_attachment=False,
        attachment_filename=f"{_id}.jsonld"
    )
