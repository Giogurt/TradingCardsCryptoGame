// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "./utils/SafeMath.sol";
import "./utils/StringsOpenZeppelin.sol";
import "./utils/Ownable.sol";


/**
* @title TradingCards
* @notice TradingCards contract allows users to submit cards that can be exchanged through the blockchain
* @dev Skill and Class properties are yet to be properly implemented
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
    mapping(address => uint) internal ownerCardCount;

    uint randNonce = 0;
    uint statsDigits = 3;
    uint classDigits = 1;
    uint skillDigits = 1;
    string cardDefaultName = "Crypto Card ";

    /**
    * @param _player - Address of the player that will receive the newly created card
    * @param _name - Name of the card
    * @param _health - Health of the card
    * @param _attack - Attack of the card
    * @param _defense - Defense of the card
    * @param _cardClass - Class of the card represented by an int
    * @param _skill - Skill of the card represented by an int
    * @dev Creates a new card and emits a NewCard event. 
    */
    function _createCard(address _player, string memory _name, uint16 _health, uint16 _attack, uint16 _defense, uint16 _cardClass, uint16 _skill) internal {
         cards.push(Card(_name, _health, _attack, _defense, _cardClass, _skill));
         uint id =  cards.length - 1;
         cardToOwner[id] = _player;
         ownerCardCount[_player] = ownerCardCount[_player].add(1);
         emit NewCard(id, _name, _health, _attack, _defense, _cardClass, _skill);
    }

    /**
    * @param _player - Address of a player
    * @param _digits - Number of digits desired for the random number
    * @dev Creates a pseudo random number
    */
    function _randMod(address _player, uint _digits) private returns(uint) {
        randNonce = randNonce.add(1);
        // This allows us to create a dinamic random number of different digit length
        uint modulus = 10 ** _digits;
        return uint(keccak256(abi.encodePacked(block.timestamp, _player, randNonce))) % modulus;
    }

    /**
    * @param _player - Address of the player that will receive the newly created card
    * @dev Creates a random card assigning pseudo random stats to the card.
    */
    function _createRandomCard(address _player) internal {
        string memory thisCardName = string.concat(cardDefaultName, StringsOpenZeppelin.toString(cards.length));
        _createCard(_player, thisCardName, uint16(_randMod(_player, statsDigits)), uint16(_randMod(_player, statsDigits)), uint16(_randMod(_player, statsDigits)), uint16(_randMod(_player, classDigits)), uint16(_randMod(_player, skillDigits)));
    }

    /**
    * @dev Creates a free random card for a new player.
    */
    function createStarterCard() public {
        require(ownerCardCount[msg.sender] == 0);
        _createRandomCard(msg.sender);
    }
}