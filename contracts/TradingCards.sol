// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
* @title TradingCards
* @notice TradingCards contract allows users to submit cards that can be exchanged through the blockchain
*/
contract TradingCards {
    struct Card {
        string name;
        uint16 health;
        uint16 attack;
        uint16 defense;
        uint16[] abilities;
    }

    Card[] public cards;

    mapping (uint => address) public cardToOwner;
    mapping(address => uint) ownerCardCount;


    function _createCard(string memory _name, uint16 _health, uint16 attack, uint16 defense, uint16, uint16[] memory abilities ) internal {}
}