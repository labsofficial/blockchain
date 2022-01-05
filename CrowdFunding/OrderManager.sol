pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./Models.sol";
import "./Ownable.sol";

contract OrderManager{
    mapping(uint256 => Models.Order) private _orderMap;
    uint256[] private _orders;
    
    event CreateOrder(address sender,uint256 orderId,uint8 currency,uint256 amount,string  receiveAddress,string  senderAddress);
    event ReviewOrder(address operator,uint256 orderId,uint8 status);

    function createOrder(
        uint256 _orderId,
        string[] memory _documents,
        uint8 _currency,
        uint256 _amount,
        string memory _receiveAddress,
        string memory _senderAddress)
    public {
        require(_orderMap[_orderId].Currency == 0,"Order is existed");

        _orderMap[_orderId] = Models.Order(
            _documents,
            _currency,
            _amount,
            _receiveAddress,
            _senderAddress,
            0
        );

        _orders.push(_orderId);
        emit CreateOrder(msg.sender,_orderId,_currency,_amount,_receiveAddress,_senderAddress);
    }

    function reviewOrder(uint256 _orderId,uint8 _status) public {
        _orderMap[_orderId].Status = _status;
        emit ReviewOrder(msg.sender,_orderId,_status);
    }

    function count() public view returns(uint256){
        return _orders.length;
    }

    function getList(uint256 _startIndex,uint256 _endIndex) public view returns(uint256[] memory orders){
        uint256 row = _endIndex - _startIndex;
        orders = new uint256[](row);

        for(uint256 i =0; i < row ;i++){
            orders[i] = _orders[_startIndex+i];
        }
    }

    function details(uint256 _orderId) public view returns(
        string[] memory signedDocuments,
        uint8 currency,
        uint256 account,
        string memory receiveAddress,
        string memory senderAddress,
        uint8 status
    ){
        Models.Order memory order = _orderMap[_orderId];
        return (order.SignedDocuments,order.Currency,order.Amount,order.ReceiveAddress,order.SenderAddress,order.Status);
    }
}