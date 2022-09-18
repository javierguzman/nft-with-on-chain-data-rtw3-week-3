// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIDs;

    mapping(uint256 => uint256) public tokenIDToLevels;

    constructor() ERC721("Chain Battles", "CBTLS") {

    }

    function generateCharacter(uint256 tokenID) public view returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
                '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
                '<rect width="100%" height="100%" fill="black" />',
                '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
                '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',"Levels: ", getLevels(tokenID), '</text>',
            '</svg>'
        );

        return string(
            abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(svg)
            )
        );
    }

    function getLevels(uint256 tokenID) public view returns (string memory) {
        uint256 levels = tokenIDToLevels[tokenID];
        return levels.toString();
    }

    function getTokenURI(uint256 tokenID) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Battles #', tokenID.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenID), '"',
            '}'
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    function mint() public {
        _tokenIDs.increment(); // we start at 0 but we want to start from 1
        uint256 newItemID = _tokenIDs.current();
        _safeMint(msg.sender, newItemID);
        tokenIDToLevels[newItemID] = 0;
        _setTokenURI(newItemID, getTokenURI(newItemID));
    }

    function train(uint256 tokenID) public {
        require(_exists(tokenID), "Please use an existing token ID");
        require(ownerOf(tokenID) == msg.sender, "You are not the owner of this token ID");
        uint256 currentLevel = tokenIDToLevels[tokenID];
        tokenIDToLevels[tokenID] = currentLevel + 1;
        _setTokenURI(tokenID, getTokenURI(tokenID));
    }
}