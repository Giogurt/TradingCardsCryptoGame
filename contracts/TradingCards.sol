// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "./utils/SafeMath.sol";
import "./utils/StringsOpenZeppelin.sol";
import "./utils/Ownable.sol";


/**
* @title TradingCards
* @notice TradingCards contract allows users to submit cards that can be exchanged through the blockchain
*/
contract TradingCards is Ownable {

    using SafeMath for uint256;
    using SafeMath16 for uint16;

    event NewCard(uint cardId, string name, uint16 health, uint16 attack, uint16 defense, uint16 cardClass, uint16 skill);

    struct Card {
        string name;
        uint16 health;
        uint16 attack;
        uint16 defense;
        uint16 cardClass;
        uint16 skill;
    }

    Card[] public cards;

    mapping (uint => address) public cardToOwner;
    mapping(address => uint) ownerCardCount;

    uint randNonce = 0;
    uint statsDigits = 3;
    uint classDigits = 1;
    uint skillDigits = 1;
    string cardDefaultName = "Crypto Card ";

    function _createCard(address _player, string memory _name, uint16 _health, uint16 _attack, uint16 _defense, uint16 _cardClass, uint16 _skill) internal {
         cards.push(Card(_name, _health, _attack, _defense, _cardClass, _skill));
         uint id =  cards.length - 1;
         cardToOwner[id] = _player;
         ownerCardCount[_player] = ownerCardCount[_player].add(1);
         emit NewCard(id, _name, _health, _attack, _defense, _cardClass, _skill);
    }

    function _randMod(address _player, uint digits) internal returns(uint) {
        randNonce = randNonce.add(1);
        uint modulus = 10 ** digits;
        return uint(keccak256(abi.encodePacked(block.timestamp, _player, randNonce))) % modulus;
    }

    function _createRandomCard(address _player) internal {
        string memory thisCardName = string.concat(cardDefaultName, StringsOpenZeppelin.toString(cards.length));
        // uint16 randHp = uint16(_randMod(statsDigits));
        // uint16 randAtk = uint16(_randMod(statsDigits));
        // uint16 randDef = uint16(_randMod(statsDigits));
        // uint16 randClass = uint16(_randMod(classDigits));
        // uint16 randSkill = uint16(_randMod(skillDigits));
        _createCard(_player, thisCardName, uint16(_randMod(_player, statsDigits)), uint16(_randMod(_player, statsDigits)), uint16(_randMod(_player, statsDigits)), uint16(_randMod(_player, classDigits)), uint16(_randMod(_player, skillDigits)));
    }

    function createStarterCard() public {
        require(ownerCardCount[msg.sender] == 0);
        _createRandomCard(msg.sender);
    }
}