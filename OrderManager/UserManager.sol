pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./Models.sol";
import "./Ownable.sol";

contract UserManager{
    mapping(uint256 => Models.User) private _userMap;
    uint256[] private _users;
    
    event KycVerification(address sender,uint256 userId,string email);
    event ReviewKyc(address operator,uint256 userId,uint8 status);

    function kycVerification(
        uint256 _userId,
        string memory _familyName,
        string memory _givenName,
        string[] memory _identityDocuments,
        string memory _selfie,
        string memory _birthDay,
        string memory _email
    ) public{
        require(_userMap[_userId].Status != 1,"User kyc information has been verified");

        _userMap[_userId] = Models.User(
            _familyName,
            _givenName,
            _identityDocuments,
            _selfie,
            _birthDay,
            _email,
            0
        );

        _users.push(_userId);
        emit KycVerification(msg.sender,_userId,_email);
    }

    function reviewKyc(uint256 _userId,uint8 _status) public {
        _userMap[_userId].Status = _status;
        
        emit ReviewKyc(msg.sender,_userId,_status);
    }

    function getList(uint256 _startIndex,uint256 _endIndex) public view returns(uint256[] memory users){
        uint256 row = _endIndex - _startIndex;
        users = new uint256[](row);

        for(uint256 i =0; i < row ;i++){
            users[i] = _users[_startIndex+i];
        }
    }

    function count() public view returns(uint256){
        return _users.length;
    }

    function details(uint256 _userId) public view returns(
        string memory familyName,
        string memory givenName,
        string[] memory identityDocuments,
        string memory selfie,
        string memory birthDay,
        string memory email,
        uint8 status
    ){
        Models.User memory user = _userMap[_userId];

        return (user.FamilyName,user.GivenName,user.IdentityDocuments,user.Selfie,user.BirthDay,user.Email,user.Status);
    }

    function validUser(uint256 _userId) public view returns(bool){
        return _userMap[_userId].Status == 1;
    }
}