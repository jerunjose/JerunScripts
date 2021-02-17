import { LightningElement, api, track } from 'lwc';

export default class MultipleFileUpload extends LightningElement {
    @api minimumFilesCount;//The minimum number of files to be uploaded
    @api maximumFilesCount;//The maximum number of files that can be uploaded
    @api initFilesCount = 1;//The number of file uploader components that are loaded up on init
    @api customErrorMessage;//A custom error message to be displayed if the minimum files are not available
    @api accept;//Pass through attribute to the accept attribute of the SingleFileUpload component
    @api recordId;//Pass through attribute to the recordId attribute of the SingleFileUpload component
    @api disableDelete;//Pass through attribute to the disableDelete attribute of the SingleFileUpload component
    @api disableSoftDeleteForInitFile;//Pass through attribute to the disableSoftDeleteForInitFile attribute of the SingleFileUpload component
    @api instanceIdPrefix = "multiFile";//The prefix to be supplied for the instanceID attribute of the SingleFileUpload component
    @api initFilesList;
    
    @track filesList;
    @track showError;
    @track errorMessage;
    @track addButtonDisabled;
    @track containerCSS;

    fileIdsToSoftDelete;

    connectedCallback() {
        this.fileIdsToSoftDelete = [];
        this.loadEmptyTable();
        this.addButtonDisabled = false;
        this.processFileRows();
    }
    
    addRow(){
        this.addFileRow();
        this.processFileRows();
    }

    removeRow(event){
        let selectedItem = event.currentTarget;
        let index = selectedItem.dataset.record;
        this.filesList.splice(index, 1);
        this.checkAddButtonCondition();
    }

    @api 
    returnFileDetails(){
        let retObj = [];
        var fileElems = this.template.querySelectorAll('c-single-file-upload');
        for(let index = 0; index < fileElems.length; index++){
            retObj.push(JSON.parse(JSON.stringify(fileElems[index].getFileDetails())));
        }
        return retObj;
    }

    @api 
    checkIfMinFilesFound(){
        let filesUploadedCount = 0;
        for (let i = 0; i < this.filesList.length; i++) {
            let file = this.filesList[i];
            if(file._fileDocumentId)
                filesUploadedCount++;
        }
        this.showError = filesUploadedCount < this.minimumFilesCount;
        if(this.showError){
            this.containerCSS = 'slds-has-error';
            if(this.customErrorMessage){
                this.errorMessage = this.customErrorMessage;
            }else
                this.errorMessage = "A minimum of "+this.minimumFilesCount+" files need to be uploaded";
        }else{
            this.containerCSS = '';
        }
        return this.showError;
    }

    checkAddButtonCondition(){
        if(this.maximumFilesCount)
            this.addButtonDisabled = this.filesList.length >= this.maximumFilesCount;
    }
    
    loadEmptyTable(){
        if(this.initFilesList)
            this.filesList = JSON.parse(JSON.stringify(this.initFilesList));
        if(!this.filesList)
            this.filesList = [{}];
        if(this.initFilesCount > this.maximumFilesCount)
            this.initFilesCount = this.maximumFilesCount;
        
        let filesToAdd = this.initFilesCount - this.filesList.length;
        for (let i = 0; i < filesToAdd; i++) {
            this.filesList.push({});
        }
        for (let i = 0; i < this.filesList.length; i++) {
            let fl = this.filesList[i];
            fl._fileDocumentId = fl.fileDocumentId;
            fl._fileName = fl.fileName;
        }
        this.checkAddButtonCondition();
    }

    addFileRow(){
        this.filesList.push({});
        this.checkAddButtonCondition();
    }

    handleFileChange(evt){
        let actionType = evt.detail.actionType;
        let fileSeriesIndex = evt.currentTarget.dataset.fileIndex;
        if(actionType === 'NewFile'){
            this.filesList[fileSeriesIndex]._fileDocumentId = evt.detail.fileDocumentId;
            this.filesList[fileSeriesIndex]._fileName = evt.detail.fileName;
        }else{
            this.filesList[fileSeriesIndex]._fileDocumentId = null;
            this.filesList[fileSeriesIndex]._fileName = null;
            if(actionType === 'SoftDelete'){
                this.fileIdsToSoftDelete.push(evt.detail.fileDocumentId);
            }
        }
        this.processFileRows();
    }

    @api 
    findSoftDeleteFiles(){
        return this.fileIdsToSoftDelete;
    }
    
    processFileRows(){
        for (let i = 0; i < this.filesList.length; i++) {
            let fl = this.filesList[i];
            fl.allowRowDelete = ((i !== 0 ) && (fl._fileDocumentId == null));
            fl.instanceId = this.instanceIdPrefix + i;
        }
    }
}