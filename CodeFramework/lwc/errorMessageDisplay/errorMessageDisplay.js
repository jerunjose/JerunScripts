import { LightningElement, api, track } from 'lwc';

export default class ErrorMessageDisplay extends LightningElement {
    @api 
    get errorObj(){
        return this._errorObj;
    }
    set errorObj(value){
        this.populateErrorDisplayObject(value);
    }

    @track _errorObj;

    populateErrorDisplayObject(errorObj){
        this._errorObj = {};
        if(errorObj){
            this._errorObj = JSON.parse(JSON.stringify(errorObj));
        }
        if(!this._errorObj.iconName)
            this._errorObj.iconName = "utility:warning";
        if(!this._errorObj.iconAltText)
            this._errorObj.iconAltText = 'Error!';
        if(!this._errorObj.title)
            this._errorObj.title = 'Error';
    }
}