pragma solidity ^0.5.0;

library Models{
    struct User{
        string FamilyName;
        string GivenName;
        string[] IdentityDocuments;
        string Selfie;
        string BirthDay;
        string Email;
        uint8 Status; //1=PendingReview,2=Pass,3=Fail
    }

    struct Order{
        string[] SignedDocuments;
        uint8 Currency;//1=Ether,2=USDT
        uint256 Amount;
        string ReceiveAddress;
        string SenderAddress;
        uint8 Status;//0=PendingReview,1=Pass,2=Fail
    }
}