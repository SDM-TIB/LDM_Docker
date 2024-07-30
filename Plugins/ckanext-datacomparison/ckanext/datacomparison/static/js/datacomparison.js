const classes_label = ['mr-2', 'text-xs', 'required'],
      classes_input_resources = ['mr-4', 'rounded-input'],
      details = document.getElementById('details-comparison');

let height_details = getHeight(details);

function createLabel(text, htmlFor, classes) {
    let label = document.createElement('label');
    label.innerText = text;
    label.htmlFor = htmlFor;
    DOMTokenList.prototype.add.apply(label.classList, classes);
    return label
}

function createInput(id_, type, placeholder, classes, required, size) {
    let input = document.createElement('input');
    DOMTokenList.prototype.add.apply(input.classList, classes);
    input.type = type;
    input.id = id_;
    input.name = id_;
    if (size !== null) {
        input.size = size;
    }
    input.placeholder = placeholder;
    input.required = required;
    return input
}

function updateIFrameHeight(difference) {
    let iframe = window.parent.document.getElementsByClassName('ckanext-datapreview').item(0).children.item(1),
        iframe_height = getHeight(iframe);
    iframe.style.height = (iframe_height + difference) + 'px';
}

function details_height_update() {
    let height_details_new = getHeight(details);
    updateIFrameHeight(height_details_new - height_details);
    height_details = height_details_new;
}

details.addEventListener('toggle', details_height_update);

function addNewResourceForm() {
    num_resources += 1;
    const submit_btn = document.getElementById('dataset_submit');
    submit_btn.remove();

    for (let i = 2; i < num_resources; i++) {
        // prevent changes to previous resources since they would be ignored
        document.getElementById('res' + i + 'label').disabled = true;
        if (i > 1) { document.getElementById('res' + i).disabled = true }
    }

    const new_label_id = 'res' + num_resources + 'label',
          new_url_id = 'res' + num_resources;

    new_resource.append(document.createElement('br'));
    new_resource.append(document.createElement('br'));
    let heading = document.createElement('b');
    heading.innerText = 'Resource ' + num_resources;
    new_resource.append(heading);
    new_resource.append(document.createElement('br'));
    new_resource.append(createLabel('Label:', new_label_id, classes_label));
    new_resource.append(createInput(new_label_id, 'text', 'name', classes_input_resources, true, 12));
    new_resource.append(createLabel('URL:', new_url_id, classes_label));
    let input_url = createInput(new_url_id, 'text', 'URL for file', classes_input_resources, true, 80);
    input_url.setAttribute('list', 'resource_list');
    input_url.oninput = function() { return populateSearchBar(this.value) };
    new_resource.append(input_url);
    new_resource.append(submit_btn);

    details_height_update();
}

let num_resources = 2,
    resource_list = document.getElementById('resource_list');
const new_resource = document.getElementById('datasets');
document.getElementById('res2').oninput = function() { return populateSearchBar(this.value) };
new_resource.onsubmit = function(event) {
    event.preventDefault();

    if (num_resources === 2) {
        const elem_res1_label = document.getElementById('res1label'),
              res1_label = ' (' + elem_res1_label.value + ')';
        for (let i = 1; i < columns.length; i++) { columns[i] = columns[i] + res1_label }
        elem_res1_label.disabled = true;
    }
    const res_new = document.getElementById('res' + num_resources).value,
          res_new_label = ' (' + document.getElementById('res' + num_resources + 'label').value + ')';

    fetch(res_new)
        .then(res => res.text())
        .then(data => {
            let data_new = Papa.parse(data, { skipEmptyLines: 'greedy' }).data,
                columns_new = data_new.shift();
            for (let i = 1; i < columns_new.length; i++) { columns_new[i] = columns_new[i] + res_new_label }

            const intersection = columns.filter(value => columns_new.includes(value));
            if (1 === 1) {
                const join_column = intersection[0],
                    idx_old = 0, //columns.indexOf(join_column),
                    idx_new = 0, //columns_new.indexOf(join_column),
                    num_cols_old = columns.length - 1,
                    num_cols_new = columns_new.length - 1;

                let columns_copy = [...columns_new];
                columns_copy.splice(idx_new, 1);
                columns = columns.concat(columns_copy);

                while (data_new.length > 0) {
                    let found = false,
                        record = data_new.shift();
                    for (let i = 0; i < data_.length; i++) {
                        if (record[idx_new] == data_[i][idx_old]) {
                            found = true;
                            record.splice(idx_new, 1);

                            let length = record.length;
                            while (length < num_cols_new) {
                                record.push(null);
                                length++;
                            }

                            data_[i] = data_[i].concat(record);
                            break;
                        }
                    }
                    if (!found) {
                        let record_old = Array(num_cols_old + 1).fill(null);
                        record_old[idx_old] = record[idx_new];
                        record.splice(idx_new, 1);
                        record = record_old.concat(record);
                        data_.push(record);
                    }
                }

                const num_cols = num_cols_old + num_cols_new + 1;
                for (let i = 0; i < data_.length; i++) {  // Take care of the old records which have not been updated yet...
                    if (data_[i].length < num_cols) { data_[i] = data_[i].concat(Array(num_cols - data_[i].length).fill(null)) }
                }

                addNewResourceForm();
            } else {
                console.log('There is either no or several matching column(s).')
            }
        })
        .catch(err => console.error(err))
        .then(_ => updateUI());
};

function populateSearchBar(name) {
    resource_list.replaceChildren();
    if (name.length < 3) { return; }  // start searching for resources from three letters

    fetch(data_package['api'] + '?query=name:' + name)
        .then(res => res.json())
        .then(data => {
            if (data['success']) {
                const resource_data = data['result']['results'];
                resource_data.forEach((res) => {
                    let option = document.createElement('option');
                    option.value = res['url'];
                    option.innerText = res['name'];
                    if (res['description']) { option.innerText += ': ' + res['description'] }
                    resource_list.append(option);
                })
            }
        })
        .catch(err => console.error(err));
}
