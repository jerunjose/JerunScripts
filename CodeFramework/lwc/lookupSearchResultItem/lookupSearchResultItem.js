import { LightningElement, api } from 'lwc';

export default class LookupSearchResultItem extends LightningElement {
    @api record;
    @api titleField;
    @api subtitleFields;
    titleValue;
    subtitleValue;

    connectedCallback(){
        this.titleValue = this.record[this.titleField];
        if(this.subtitleFields){
            this.subtitleValue = '';
            for(let i = 0; i < this.subtitleFields.length; i++){
                let fldValue = this.record[this.subtitleFields[i]];
                if(fldValue)
                    this.subtitleValue += ' • '+fldValue;
            }
            this.subtitleValue = this.subtitleValue.slice(3);
        }
    }

    // This method handles the selection of lookup value
    handleSelect() {
        // Event will be triggerred and bubbled to parent and grandparent.
        // Check the parameters passed.
        const selectEvent = new CustomEvent('lookupselect', {
            detail: this.record,
            bubbles: true,
            composed: true
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }
}