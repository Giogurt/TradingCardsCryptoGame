// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "./CardGame.sol";
import "./utils/ERC721.sol";
import "./utils/SafeMath.sol";

contract CardOwnership is CardGame, ERC721 {

  using SafeMath for uint256;

  mapping (uint => address) cardApprovals;

  function balanceOf(address _owner) external view override returns (uint256) {
    return ownerCardCount[_owner];
  }

  function ownerOf(uint256 _tokenId) external view override returns (address) {
    return cardToOwner[_tokenId];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) internal override {
    _approve(address(0), _tokenId);
    ownerCardCount[_to] = ownerCardCount[_to].add(1);
    ownerCardCount[msg.sender] = ownerCardCount[msg.sender].sub(1);
    cardToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) external override payable {
    require (cardToOwner[_tokenId] == msg.sender || cardApprovals[_tokenId] == msg.sender);
    _transfer(_from, _to, _tokenId);
  }

  function trade(address _from, address _to, uint256 _tokenIdFrom, uint256 _tokenIdTo) external payable {
    require (cardApprovals[_tokenIdFrom] == _to || cardApprovals[_tokenIdTo] == _from);
    _transfer(_from, _to, _tokenIdFrom);
    _transfer(_to, _from, _tokenIdTo);
  }

  function _approve(address _approved, uint256 _tokenId) internal virtual override   {
    cardApprovals[_tokenId] = _approved;
    emit Approval(msg.sender, _approved, _tokenId);
  }

  function approve(address _to, uint256 _tokenId) public virtual override payable onlyOwnerOf(_tokenId){
      _approve(_to, _tokenId);
  }
}