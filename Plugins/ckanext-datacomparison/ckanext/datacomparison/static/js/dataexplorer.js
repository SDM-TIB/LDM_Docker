const arrayColumn = (arr, n) => arr.map(x => x[n]);

let height_searchBuilder;

function openTab(ele, tabName) {
    let i, tabcontent, tablinks;

    // Get all elements with class="tabcontent" and hide them
    tabcontent = document.getElementsByClassName('tabcontent');
    for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = 'none';
    }

    // Get all elements with class="tablinks" and remove the class "active"
    tablinks = document.getElementsByClassName('tablinks');
    for (i = 0; i < tablinks.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(' active', '');
    }

    // Show the current tab, and add an "active" class to the button that opened the tab
    document.getElementById(tabName).style.display = 'block';
    ele.className += ' active';
}

document.getElementById('defaultOpen').click();  // open default tab

function getHeight(element) {
    return parseFloat(getComputedStyle(element).height.slice(0, -2))
}

const chart_builder = document.getElementById('chartBuilder');
chart_builder.onsubmit = function(event) {
    event.preventDefault();
    document.getElementById('guidingText').style.display = 'none';

    const chart_type = document.getElementById('chartType').value,
          group_column = columns.indexOf(document.getElementById('xAxis').value),
          checked_inputs_yAxis = document.querySelectorAll('input[name=yAxis]:checked');

    const data_xAxis = arrayColumn(data_, group_column);
    let traces = [];
    for (let i = 0; i < checked_inputs_yAxis.length; i++) {
        const dataset_name = checked_inputs_yAxis[i].value,
              dataset_idx = columns.indexOf(dataset_name);

        switch (chart_type) {
            case 'line':
                traces.push({
                    x: data_xAxis,
                    y: arrayColumn(data_, dataset_idx),
                    name: dataset_name,
                    type: 'scatter',
                    mode: 'lines',
                    line: {
                        'shape': 'spline',
                        'smoothing': 1.3
                    }
                });
                break;
            case 'scatter':
                traces.push({
                    x: data_xAxis,
                    y: arrayColumn(data_, dataset_idx),
                    name: dataset_name,
                    type: 'scatter',
                    mode: 'markers'
                });
                break;
            case 'bar':
                traces.push({
                    x: data_xAxis,
                    y: arrayColumn(data_, dataset_idx),
                    name: dataset_name,
                    type: 'bar'
                });
                break;
            default:
                console.log('Sorry not yet implemented!');
        }
    }
    let layout = { hovermode: 'x unified', xaxis: data_xAxis };
    if (document.getElementById('logScale').checked) {
        layout['yaxis'] = {
            type: 'log',
            autorange: true
        }
    }

    Plotly.newPlot('gd', traces, layout, { displaylogo: false, responsive: true });
}

let data_explorer = document.getElementById('data-explorer-comparison'),
    data_package = JSON.parse(data_explorer.dataset.datapackage);

let columns = null,
    data_ = [];
const xAxis = document.getElementById('xAxis'),
      yAxis = document.getElementById('yAxis');

function setNumberRows(count) { document.getElementById('totalRows').innerText = 'Total rows: ' + count }

function loadData() {
    if ('api' in data_package['resources'][0]) {
        fetch(data_package['resources'][0]['api'])
            .then(res => res.json())
            .then(data => {
                let records = data.result.records;
                for (let i = 0; i < records.length; i++) {
                    const record = records[i];
                    let values = Object.values(record);
                    values.shift();
                    data_.push(values)
                    if (i === 0) { columns = Object.keys(record); }
                }
                columns.shift();  // removing the _id column

                updateUI();
                height_searchBuilder = getHeight(document.getElementsByClassName('dtsb-group').item(0));
            })
            .catch(err => console.error(err));
    } else {
        fetch(data_package['resources'][0]['path'])
            .then(res => res.text())
            .then(data => {
               data_ = Papa.parse(data, { skipEmptyLines: 'greedy' }).data;
               columns = data_.shift();

                updateUI();
                height_searchBuilder = getHeight(document.getElementsByClassName('dtsb-group').item(0));
            })
            .catch(err => console.error(err));
    }
}
loadData();

function updateUI() {
    initChartBuilder();
    setNumberRows(data_.length);

    let colDef = [];
    for (const j in columns) { colDef.push({ title: columns[j] }) }

    if (DataTable.isDataTable('#comparison-table')) {
        new DataTable.Api('#comparison-table').clear().destroy();
        document.getElementById('comparison-table').innerHTML = '';
    }
    new DataTable('#comparison-table', {
        destroy: true,
        dom: 'Qfrtip',
        columns: colDef,
        data: data_,
        searchBuilder: {
            filterChanged: function() {
                let height_searchBuilder_new = getHeight(document.getElementsByClassName('dtsb-group').item(0));
                updateIFrameHeight(height_searchBuilder_new - height_searchBuilder);
                height_searchBuilder = height_searchBuilder_new;
            }
        }
    });
}

function initChartBuilder() {
    xAxis.replaceChildren();
    yAxis.replaceChildren();

    for (let i = 0; i < columns.length; i++) {
        const column = columns[i];

        // xAxis
        let option = document.createElement('option');
        option.text = column;
        xAxis.add(option);

        // yAxis
        let label = document.createElement('label');
        label.classList.add('block', 'font-bold', 'text-white');
        let input = document.createElement('input');
        input.id = 'yAxis' + i;
        input.classList.add('ml-2', 'mr-2', 'leading-tight');
        input.type = 'checkbox';
        input.name = 'yAxis';
        input.value = column;
        if (i === 0) {
            input.checked = true;
        }
        let span = document.createElement('span');
        span.classList.add('text-xs');
        span.innerText = column;
        label.appendChild(input);
        label.appendChild(span);
        yAxis.appendChild(label);
    }
}
