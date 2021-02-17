import { LightningElement, api, track } from 'lwc';
import deleteContentDocument from '@salesforce/apex/SingleFileUploadController.deleteContentDocument';

export default class SingleFileUpload extends LightningElement {
    @api instanceId;

    @api fileName;
    @api fileDocumentId;
    @api fileUploadedBy;
    @api fileUploadedDate;

    @api label;
    @api accept;
    @api recordId;

    @api disableDelete;
    @api disableSoftDeleteForInitFile;

    @track _fileName;// = file.name;
    @track _fileDocumentId;// = file.documentId;
    @track isFileLoaded;
    @track deleteFileOnSubmit;
    @track showError;
    @track errorMessage;
    @track ApexResponse;
    @track loadFinished;
    @track containerCSS;
    @track fileUploadedByAvailable;
    @track fileDownloadURL;
    @track fileDownloadTitle;
    fileChangeEvt;
   
    connectedCallback(){
        this.initializeComponent();
    }

    @api
    initializeComponent(){
        this.fileUploadedByAvailable = false;
        this.loadFileVariables();
        this.checkIfFileLoaded();
        if(this.disableSoftDeleteForInitFile){
            this.deleteFileOnSubmit = this.isFileLoaded;
        }
        this.ApexResponse = {};
        this.loadFinished = true;
    }

    @api getFileDetails(){
        let retObj = {};
        retObj.fileName = this._fileName;
        retObj.fileDocumentId = this._fileDocumentId;
        return retObj;
    }

    loadFileVariables(){
        this._fileName = this.fileName;
        this._fileDocumentId = this.fileDocumentId;
    }

    checkIfFileLoaded(){
        if(this._fileDocumentId){
            this.isFileLoaded = true;
            this.fileDownloadURL = '/sfc/servlet.shepherd/document/download/' +this._fileDocumentId;
            this.fileDownloadTitle = this._fileName == null ? 'Download' : this._fileName;
        }else{
            this.isFileLoaded = false;
        }
        if(this.fileUploadedBy)
            this.fileUploadedByAvailable = true;
    }
    
    handleUploadFinished(event){
        this.isFileLoaded = true;
        let files = event.detail.files;
        files.forEach((file) => {
            this._fileName = file.name;
            this._fileDocumentId = file.documentId;
            this.checkIfFileLoaded();
        });
        this.deleteFileOnSubmit = true;
        this.clearErrors();
        this.fireActionEvent('NewFile');
    }
    
    clearErrors(){
		this.showError = false;
    }

    fireActionEvent(actionType){
        const fileChangeEvt = new CustomEvent(
            'filechange',
            { 
                detail: {
                "actionType": actionType,
                "instanceId": this.instanceId,
                "fileName": this._fileName,
                "fileDocumentId": this._fileDocumentId
                }
            }
        );
        this.dispatchEvent(fileChangeEvt);
    }

    deleteFile(){
        if(this.deleteFileOnSubmit){
            deleteContentDocument({ contentDocumentId: this._fileDocumentId})
            .then((resp) => {
                this.ApexResponse = resp;
                if(!resp.isException){
                    this.fireActionEvent('HardDelete');
                    this.unloadFile();
                }
            })
            .catch(() => {
                //alert('Something went wrong...');
            });
        }else{
            this.fireActionEvent('SoftDelete');
            this.unloadFile();
        }
    }

    @api
    markError(showError, errorMessage){
        this.showError = showError;
        this.errorMessage = errorMessage;
        if(!this.errorMessage)
            this.errorMessage = 'Please upload a file';
        if(this.showError){
            this.containerCSS = 'slds-has-error';
        }else{
            this.containerCSS = '';
        }
    }

    unloadFile(){
        this._fileName = null;
        this._fileDocumentId = null;
        this.checkIfFileLoaded();
	}
}