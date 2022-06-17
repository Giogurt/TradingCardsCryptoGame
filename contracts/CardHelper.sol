// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "./TradingCards.sol";
import "./utils/SafeMath.sol";

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

  modifier onlyOwnerOf(uint _cardId) {
    require(msg.sender == cardToOwner[_cardId]);
    _;
  }

  function withdraw() external onlyOwner {
    address payable _owner = payable(owner());
    _owner.transfer(address(this).balance);
    emit NewWithdraw(_owner);
  }

  function setNameChangeFee(uint _fee) external onlyOwner {
    nameChangeFee = _fee;
    emit NameChangeFeeModified(nameChangeFee);
  }

  function setUpgradeCardStatFee(uint _fee) external onlyOwner {
    upgradeCardStatFee = _fee;
    emit UpgradeCardStatFeeModified(upgradeCardStatFee);
  }

  function setBoosterPackFee(uint _fee) external onlyOwner {
    boosterPackFee = _fee;
    emit BoosterPackFeeModified(boosterPackFee);
  }

  function setBoosterPackQuantity(uint8 _quantity) external onlyOwner {
    boosterPackQuantity = _quantity;
    emit BoosterPackQuantityModified(boosterPackQuantity);
  }

  function setStatsDigits(uint _digits) external onlyOwner {
    statsDigits = _digits;
    emit StatsDigitsModified(statsDigits);
  }

  function setClassDigits(uint _digits) external onlyOwner {
    classDigits = _digits;
    emit ClassDigitsModified(classDigits);
  }

  function setSkillDigits(uint _digits) external onlyOwner {
    skillDigits = _digits;
    emit SkillDigitsModified(skillDigits);
  }

  function setStatUpgradeAmount(uint16 _amount) external onlyOwner {
    statUpgradeAmount = _amount;
    emit StatUpgradeAmountModified(statUpgradeAmount);
  }

  function _generateBoosterPack(address _player) internal {
      for(uint i = 0; i < boosterPackQuantity; i++) {
          _createRandomCard(_player);
      }
  }

  function acquireBoosterPack() payable external {
    require(msg.value == boosterPackFee);
    _generateBoosterPack(msg.sender);
    emit NewAcquiredBoosterPack(msg.sender);
  }

  function _upgradeCardStats(uint _cardId) internal {
      cards[_cardId].health = cards[_cardId].health.add(statUpgradeAmount);
      cards[_cardId].attack = cards[_cardId].attack.add(statUpgradeAmount);
      cards[_cardId].defense = cards[_cardId].defense.add(statUpgradeAmount);
      emit UpgradedCardStats(_cardId, cards[_cardId].health, cards[_cardId].attack, cards[_cardId].defense);
  }

  /**
  * @param _stat - 1 - health, 2 - attack, 3 - defense
  * @dev upgrades an especific card stat
  */
  function upgradeCardStat(uint _cardId, uint8 _stat) payable external onlyOwnerOf(_cardId) returns(uint16) {
    require(msg.value == upgradeCardStatFee);
    require(_stat == 1 || _stat == 2 || _stat == 3);
    if(_stat == 1) {
      cards[_cardId].health = cards[_cardId].health.add(10);
      emit UpgradedCardStat(_cardId, "Health", cards[_cardId].health);
      return cards[_cardId].health;
    } else if (_stat == 2) {
      cards[_cardId].attack = cards[_cardId].attack.add(10);
      emit UpgradedCardStat(_cardId, "Attack", cards[_cardId].attack);
      return cards[_cardId].attack;
    } else {
      cards[_cardId].defense = cards[_cardId].defense.add(10);
      emit UpgradedCardStat(_cardId, "Defense", cards[_cardId].defense);
      return cards[_cardId].defense;
    }
  }

  function changeName(uint _cardId, string calldata _newName) payable external onlyOwnerOf(_cardId) {
    require(msg.value == nameChangeFee);
    cards[_cardId].name = _newName;
    emit CardNameChanged(_cardId, cards[_cardId].name);
  }

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
