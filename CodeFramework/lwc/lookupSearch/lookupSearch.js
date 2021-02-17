import { LightningElement, track, api, wire} from 'lwc';
import getLookupSerachRecords from '@salesforce/apex/LookupController.getLookupSerachRecords';
export default class LookupSearch extends LightningElement {
    // Tracked properties
    @track records;
    @track noRecordsFlag = false;
    @track showoptions = false;
    @track searchString = '';
    @track selectedName;
    // API properties
    @api label;
    @api selectedSobject;
    @api searchSoqlWhereClause;
    @api recordLimit;
    @api titleField;
    @api subtitleFields;

    searchKeyTimeout;
    searchStringTemp;
    // Wire method to function, which accepts the Search String, Dynamic SObject, Record Limit, Search Field
    @wire(getLookupSerachRecords, {
        searchString : '$searchString',
        selectedSObject : '$selectedSobject',
        SOQLWhereClause : '$searchSoqlWhereClause',
        titleField : '$titleField',
        subtitleFields : '$subtitleFields',
        recordLimit : '$recordLimit'})
    wiredContacts({ error, data }) {
        this.noRecordsFlag = 0;
        if (data) {
            this.records = null;
            this.records = data;
            this.error = undefined;
            this.noRecordsFlag = this.records.length === 0 ? true : false;
            this.showoptions = !this.noRecordsFlag;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }
    // handle event called lookupselect
    handlelookupselect(event){
        this.selectedName = event.detail.Name;
        this.showoptions = false;
        this.noRecordsFlag = false;
    }
    // key change on the text field
    handleKeyChange(event) {
        this.searchStringTemp = event.target.value;
        clearTimeout(this.searchKeyTimeout);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.searchKeyTimeout = setTimeout(() => {
            this.processKeyChange();
        }, 500);
    }

    processKeyChange(){
        this.showoptions = false;
        this.noRecordsFlag = false;
        this.searchString = this.searchStringTemp;
    }
}