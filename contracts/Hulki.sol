pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Hulki is ERC721URIStorage, Ownable {
    using Strings for uint256;

    struct HulkiInfo {
        string bannerURI;
        string beastURI;
        string warURI;
        string battleURI;
        string valhallaURI;
        uint256 bannerTS;
        uint256 beastTS;
        uint256 warTS;
        uint256 battleTS;
        uint256 valhallaTS;
        uint256 price;
    }

    /** @notice token uris, counters and supply */
    HulkiInfo hulkiInfo;
    /** @notice approved managers, such as staking contract */
    mapping(address => bool) public approved;
    /** @notice token IDs, required for staking */
    uint256[] public mintedInLastRoundTokens;
    /** @notice minting (5) rounds */
    uint8 public round;

    /** @notice counters for nft ids */
    uint256 bannerId = 0;
    uint256 beastId = 1800;
    uint256 warId = 2400;
    uint256 battleId = 2800;
    uint256 valhallaId = 3000;

    constructor() ERC721("Hulki", "H") {
        approved[msg.sender] = true;
    }

    /**
     * @notice public mint function
     * @param _mode => 0.called from staking contract
     * 1.multipack mint
     * @param _amount => amount of nfts to mint
     * @param _evo => evolution of nft
     * @param _tokenId => token to burn. in case evolution
     * is chosen as a mint option.
     */
    function mint(
        uint8 _mode,
        uint8 _amount,
        uint8 _evo,
        uint256 _tokenId
    ) public payable {
        if (_mode == 0) {
            // staking mint
            require(approved[msg.sender], "msg.sender is not approved");
            evolve(_evo, _tokenId, msg.sender);
        } else if (_mode == 1) {
            //require(msg.value >= hulkiInfo.price * _amount, "Price not paid");
            if (round == 0) {
                _lowMint(0, _amount, msg.sender, false);
                if (_amount >= 5 && _amount < 10) {
                    _lowMint(1, 1, msg.sender, false);
                } else if (_amount >= 10 && _amount < 15) {
                    _lowMint(2, 1, msg.sender, false);
                } else if (_amount >= 15 && _amount < 20) {
                    _lowMint(3, 1, msg.sender, false);
                } else if (_amount >= 20) {
                    _lowMint(4, 1, msg.sender, false);
                }
            } else if (round == 1) {
                _lowMint(0, _amount, msg.sender, false);
                if (_amount >= 5 && _amount < 10) {
                    _lowMint(1, 1, msg.sender, false);
                } else if (_amount >= 10 && _amount < 15) {
                    _lowMint(2, 1, msg.sender, false);
                } else if (_amount >= 15) {
                    _lowMint(3, 1, msg.sender, false);
                } 
            } else if (round == 2) {
                _lowMint(0, _amount, msg.sender, false);
                if (_amount >= 5 && _amount < 10) {
                    _lowMint(1, 1, msg.sender, false);
                } else if (_amount >= 10) {
                    _lowMint(2, 1, msg.sender, false);
                }
            } else if (round == 3) {
                _lowMint(0, _amount, msg.sender, false);
                if (_amount >= 5) {
                    _lowMint(1, 1, msg.sender, false);
                }
            } else if (round == 4) {
                _lowMint(0, _amount, msg.sender, true);
                
            }
        }
    }

    /**
    * @notice evolution is a process of sending lower evo tokens 
    * and in exchange getting higher evo token. Called by staking
    * contract.
    * @param _evo => level of evolution
    * @param _tokenId => id of token to burn
    * @param _to => "msg.sender"
     */
    function evolve(
        uint8 _evo,
        uint256 _tokenId,
        address _to
    ) internal {
        _burn(_tokenId);
        if (_evo != 5) {
            _lowMint(_evo + 1, 1, _to, false);
        } else {
            revert("Cant evolve valhalla");
        }
    }

    /**
     * @notice internal mint function for cleaner code
     * @param _evo => stands for evolution of nft
     * @param _amount => amount of nfts to mint
     *
     * since we have multiple tiers of tokens, we need to set
     * separate tokenURIs for each. using openzeppelin library,
     * during the mint each token will get their own custom URI.
     */
    function _lowMint(
        uint8 _evo,
        uint256 _amount,
        address _to,
        bool _lastRound
    ) internal {
        if (_evo == 0) {
            //require(bannerId + _amount <= hulkiInfo.bannerTS);
            for (uint256 x; x < _amount; x++) {
                bannerId++;
                _safeMint(_to, bannerId);
                _setTokenURI(
                    bannerId,
                    string(
                        abi.encodePacked(
                            hulkiInfo.bannerURI,
                            bannerId.toString(),
                            ".json"
                        )
                    )
                );

                if (_lastRound) {
                    mintedInLastRoundTokens.push(bannerId);
                }
            }
        } else if (_evo == 1) {
            //require(beastId + _amount <= hulkiInfo.beastTS);
            for (uint256 x; x < _amount; x++) {
                beastId++;
                _safeMint(_to, beastId);
                _setTokenURI(
                    beastId,
                    string(
                        abi.encodePacked(
                            hulkiInfo.beastURI,
                            beastId.toString(),
                            ".json"
                        )
                    )
                );
            }
        } else if (_evo == 2) {
            //require(warId + _amount <= hulkiInfo.warTS);
            for (uint256 x; x < _amount; x++) {
                warId++;
                _safeMint(_to, warId);
                _setTokenURI(
                    warId,
                    string(
                        abi.encodePacked(
                            hulkiInfo.warURI,
                            warId.toString(),
                            ".json"
                        )
                    )
                );
            }
        } else if (_evo == 3) {
            //require(battleId + _amount <= hulkiInfo.battleTS);
            for (uint256 x; x < _amount; x++) {
                battleId++;
                _safeMint(_to, battleId);
                _setTokenURI(
                    battleId,
                    string(
                        abi.encodePacked(
                            hulkiInfo.battleURI,
                            battleId.toString(),
                            ".json"
                        )
                    )
                );
            }
        } else if (_evo == 4) {
            //require(valhallaId + _amount <= hulkiInfo.valhallaTS);
            for (uint256 x; x < _amount; x++) {
                valhallaId++;
                _safeMint(_to, valhallaId);
                _setTokenURI(
                    valhallaId,
                    string(
                        abi.encodePacked(
                            hulkiInfo.valhallaURI,
                            valhallaId.toString(),
                            ".json"
                        )
                    )
                );
            }
        } else {
            revert("Wrong _evo");
        }
    }

    /**
     * @notice manage approved members. should be handled with care
     * @param _user => address of manager
     * @param _state => remove or add them
     */
    function setApproved(address _user, bool _state) public onlyOwner {
        approved[_user] = _state;
    }

    /**
     * @notice set hulki info
     * @param _bannerUri => etc, token URIs
     * @param _bannerTs => etc, total supply
     * @param _price => token price in eth (*10**18)
     */
    function setHulkiInfo(
        string memory _bannerUri,
        string memory _beastUri,
        string memory _warUri,
        string memory _battleUri,
        string memory _valhallaUri,
        uint256 _bannerTs,
        uint256 _beastTs,
        uint256 _warTs,
        uint256 _battleTs,
        uint256 _valhallaTs,
        uint256 _price
    ) public onlyOwner {
        hulkiInfo = HulkiInfo(
            _bannerUri,
            _beastUri,
            _warUri,
            _battleUri,
            _valhallaUri,
            _bannerTs,
            _beastTs,
            _warTs,
            _battleTs,
            _valhallaTs,
            _price
        );
    }

    /**
     * @notice set minting round, 0 to 4 (1 to 5)
     * @param _round => 0 to 4 (1 to 5)
     */
    function setRound(uint8 _round) public onlyOwner {
        require(_round <= 4, "Wrong round");
        round = _round;
    }

    function getTokenIdsMintedInLastRound() public view returns (uint256[] memory) {
        return mintedInLastRoundTokens;
    }
}
