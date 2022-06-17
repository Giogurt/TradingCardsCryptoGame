// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "./TradingCards.sol";
import "./utils/SafeMath.sol";

/**
* @title CardHelper
* @dev Helper functions for interacting with the contract logic.
*/
contract CardHelper is TradingCards {

  using SafeMath16 for uint16;

  event NewWithdraw(address payable owner);
  event NameChangeFeeModified(uint fee);
  event UpgradeCardStatFeeModified(uint fee);
  event BoosterPackFeeModified(uint fee);
  event BoosterPackQuantityModified(uint quantity);
  event StatsDigitsModified(uint digits);
  event ClassDigitsModified(uint digits);
  event SkillDigitsModified(uint digits);
  event StatUpgradeAmountModified(uint amount);
  event NewAcquiredBoosterPack(address owner);
  event UpgradedCardStats(uint cardId, uint16 health, uint16 attack, uint16 defense);
  event UpgradedCardStat(uint cardId, string statType, uint16 stat);
  event CardNameChanged(uint cardId, string name);

  uint nameChangeFee = 0.001 ether;
  uint upgradeCardStatFee = 0.005 ether;
  uint boosterPackFee = 0.004 ether;
  uint8 boosterPackQuantity = 5;

  uint16 statUpgradeAmount = 10;

  /**
  * @param _cardId - Id of the card
  * @dev Checks if the sender of the function is the owner of the card specified
  */
  modifier onlyOwnerOf(uint _cardId) {
    require(msg.sender == cardToOwner[_cardId]);
    _;
  }

  /**
  * @dev Allows the owner to withdraw the ether stored in the contract
  */
  function withdraw() external onlyOwner {
    address payable _owner = payable(owner());
    _owner.transfer(address(this).balance);
    emit NewWithdraw(_owner);
  }

  /**
  * @param _fee - New fee to be applied
  * @dev Modifies the fee based on the newly specified fee
  */
  function setNameChangeFee(uint _fee) external onlyOwner {
    nameChangeFee = _fee;
    emit NameChangeFeeModified(nameChangeFee);
  }

  /**
  * @param _fee - New fee to be applied
  * @dev Modifies the fee based on the newly specified fee
  */
  function setUpgradeCardStatFee(uint _fee) external onlyOwner {
    upgradeCardStatFee = _fee;
    emit UpgradeCardStatFeeModified(upgradeCardStatFee);
  }

  /**
  * @param _fee - New fee to be applied
  * @dev Modifies the fee based on the newly specified fee
  */
  function setBoosterPackFee(uint _fee) external onlyOwner {
    boosterPackFee = _fee;
    emit BoosterPackFeeModified(boosterPackFee);
  }

  /**
  * @param _quantity - New quantity to be applied
  * @dev Modifies the quantity based on the newly specified quantity
  */
  function setBoosterPackQuantity(uint8 _quantity) external onlyOwner {
    boosterPackQuantity = _quantity;
    emit BoosterPackQuantityModified(boosterPackQuantity);
  }

  /**
  * @param _digits - New length of digits to be applied
  * @dev Modifies the length of the digits used to create new cards
  */
  function setStatsDigits(uint _digits) external onlyOwner {
    statsDigits = _digits;
    emit StatsDigitsModified(statsDigits);
  }

  /**
  * @param _digits - New length of digits to be applied
  * @dev Modifies the length of the digits used to create new cards
  */
  function setClassDigits(uint _digits) external onlyOwner {
    classDigits = _digits;
    emit ClassDigitsModified(classDigits);
  }

  /**
  * @param _digits - New length of digits to be applied
  * @dev Modifies the length of the digits used to create new cards
  */
  function setSkillDigits(uint _digits) external onlyOwner {
    skillDigits = _digits;
    emit SkillDigitsModified(skillDigits);
  }

  /**
  * @param _amount - New amount to be applied
  * @dev Modifies the amount of ether needed to upgrade a card stat
  */
  function setStatUpgradeAmount(uint16 _amount) external onlyOwner {
    statUpgradeAmount = _amount;
    emit StatUpgradeAmountModified(statUpgradeAmount);
  }

  /**
  * @param _player - Address of the player that will receive the cards in the booster pack
  * @dev generates a booster pack with a specified amount of random generated cards
  */
  function _generateBoosterPack(address _player) internal {
      // Generates a dinamic amount of cards per booster pack depending on the quantity defined
      for(uint i = 0; i < boosterPackQuantity; i++) {
          _createRandomCard(_player);
      }
  }

  /**
  * @dev Allows a player to spend ether to aquire a booster pack
  */
  function acquireBoosterPack() payable external {
    require(msg.value == boosterPackFee);
    _generateBoosterPack(msg.sender);
    emit NewAcquiredBoosterPack(msg.sender);
  }

  /**
  * @param _cardId - Id of the card that will be upgraded
  * @dev Adds a determined amount of stat points to the health, attack and defense stats
  */
  function _upgradeCardStats(uint _cardId) internal {
      cards[_cardId].health = cards[_cardId].health.add(statUpgradeAmount);
      cards[_cardId].attack = cards[_cardId].attack.add(statUpgradeAmount);
      cards[_cardId].defense = cards[_cardId].defense.add(statUpgradeAmount);
      emit UpgradedCardStats(_cardId, cards[_cardId].health, cards[_cardId].attack, cards[_cardId].defense);
  }

  /**
  * @param _cardId - Id of the card that will be upgraded
  * @param _stat - 1 - health, 2 - attack, 3 - defense
  * @dev Lets the player upgrade an especific card stat by spending a determined amount of ether
  */
  function upgradeCardStat(uint _cardId, uint8 _stat) payable external onlyOwnerOf(_cardId) returns(uint16) {
    require(msg.value == upgradeCardStatFee);
    require(_stat == 1 || _stat == 2 || _stat == 3);
    
    // Depending on the stat that was specified we determine where to add the stat points
    if(_stat == 1) {
      cards[_cardId].health = cards[_cardId].health.add(statUpgradeAmount);
      emit UpgradedCardStat(_cardId, "Health", cards[_cardId].health);
      return cards[_cardId].health;
    } else if (_stat == 2) {
      cards[_cardId].attack = cards[_cardId].attack.add(statUpgradeAmount);
      emit UpgradedCardStat(_cardId, "Attack", cards[_cardId].attack);
      return cards[_cardId].attack;
    } else {
      cards[_cardId].defense = cards[_cardId].defense.add(statUpgradeAmount);
      emit UpgradedCardStat(_cardId, "Defense", cards[_cardId].defense);
      return cards[_cardId].defense;
    }
  }

  /**
  * @param _cardId - Id of the card that will be modified
  * @param _newName - New card name
  * @dev Modifies the card name for a determined amount of ether
  */
  function changeName(uint _cardId, string calldata _newName) payable external onlyOwnerOf(_cardId) {
    require(msg.value == nameChangeFee);
    cards[_cardId].name = _newName;
    emit CardNameChanged(_cardId, cards[_cardId].name);
  }

  /**
  * @param _owner - Address of a specified player
  * @return Array with the id cards of that player
  * @dev Gets the id of all the cards that a specified player owns
  */
  function getCardsByOwner(address _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerCardCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < cards.length; i++) {
      if (cardToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

}
