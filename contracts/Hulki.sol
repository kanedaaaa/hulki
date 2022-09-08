pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Hulki is ERC721URIStorage, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

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
    uint256[] public valhallaTokens;
    uint256[] public battleTokens;
    uint256[] public warTokens;
    uint256[] public beastTokens;
    uint256[] public mintedInLastRoundTokens;
    /** @notice minting (5) rounds */
    uint8 public _round;

    /** @notice counters for nft ids */
    Counters.Counter bannerID;
    Counters.Counter beastID;
    Counters.Counter warID;
    Counters.Counter battleID;
    Counters.Counter valhallaID;

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

            if (_evo == 4) {
                valhallaTokens.push(_tokenId);
            }
        } else if (_mode == 1) {
            require(msg.value >= hulkiInfo.price * _amount, "Price not paid");
            if (_round == 0) {
                _lowMint(0, _amount, msg.sender);
                if (_amount >= 5 && _amount < 10) {
                    _lowMint(1, 1, msg.sender);
                } else if (_amount >= 10 && _amount < 15) {
                    _lowMint(2, 1, msg.sender);
                } else if (_amount >= 15 && _amount < 20) {
                    _lowMint(3, 1, msg.sender);
                } else if (_amount >= 20) {
                    _lowMint(4, 1, msg.sender);
                    valhallaTokens.push(_tokenId);
                }
            } else if (_round == 1) {
                _lowMint(0, _amount, msg.sender);
                if (_amount >= 5 && _amount < 10) {
                    _lowMint(1, 1, msg.sender);
                } else if (_amount >= 10 && _amount < 15) {
                    _lowMint(2, 1, msg.sender);
                } else if (_amount >= 15) {
                    _lowMint(3, 1, msg.sender);
                }
            } else if (_round == 2) {
                _lowMint(0, _amount, msg.sender);
                if (_amount >= 5 && _amount < 10) {
                    _lowMint(1, 1, msg.sender);
                } else if (_amount >= 10) {
                    _lowMint(2, 1, msg.sender);
                }
            } else if (_round == 3) {
                _lowMint(0, _amount, msg.sender);
                if (_amount >= 5) {
                    _lowMint(1, 1, msg.sender);
                }
            } else if (_round == 5) {
                _lowMint(0, _amount, msg.sender);
            }
        }
    }

    function evolve(
        uint8 _evo,
        uint256 _tokenId,
        address _to
    ) internal {
        _burn(_tokenId);
        if (_evo != 5) {
            _lowMint(_evo + 1, 1, _to);
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
        address _to
    ) internal {
        if (_evo == 0) {
            require(
                bannerID.current() + _amount <= hulkiInfo.bannerTS
            );
            for (uint256 x; x < _amount; x++) {
                bannerID.increment();
                _safeMint(_to, bannerID.current());
                _setTokenURI(
                    bannerID.current(),
                    string(
                        abi.encodePacked(
                            hulkiInfo.bannerURI,
                            bannerID.current().toString(),
                            ".json"
                        )
                    )
                );
            }
        } else if (_evo == 1) {
            require(beastID.current() + _amount <= hulkiInfo.beastTS);
            for (uint256 x; x < _amount; x++) {
                beastID.increment();
                _safeMint(_to, beastID.current());
                _setTokenURI(
                    beastID.current(),
                    string(
                        abi.encodePacked(
                            hulkiInfo.beastURI,
                            beastID.current().toString(),
                            ".json"
                        )
                    )
                );
            }
        } else if (_evo == 2) {
            require(warID.current() + _amount <= hulkiInfo.warTS);
            for (uint256 x; x < _amount; x++) {
                warID.increment();
                _safeMint(_to, warID.current());
                _setTokenURI(
                    warID.current(),
                    string(
                        abi.encodePacked(
                            hulkiInfo.warURI,
                            warID.current().toString(),
                            ".json"
                        )
                    )
                );
            }
        } else if (_evo == 3) {
            require(
                battleID.current() + _amount <= hulkiInfo.battleTS
            );
            for (uint256 x; x < _amount; x++) {
                battleID.increment();
                _safeMint(_to, battleID.current());
                _setTokenURI(
                    battleID.current(),
                    string(
                        abi.encodePacked(
                            hulkiInfo.battleURI,
                            battleID.current().toString(),
                            ".json"
                        )
                    )
                );
            }
        } else if (_evo == 4) {
            require(
                valhallaID.current() + _amount <= hulkiInfo.valhallaTS
            );
            for (uint256 x; x < _amount; x++) {
                valhallaID.increment();
                _safeMint(_to, valhallaID.current());
                _setTokenURI(
                    valhallaID.current(),
                    string(
                        abi.encodePacked(
                            hulkiInfo.valhallaURI,
                            valhallaID.current().toString(),
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
}
