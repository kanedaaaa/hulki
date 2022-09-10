pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Hulki is ERC721URIStorage, Ownable {
    using Strings for uint256;

    /** @notice token uris and price per token */
    string startURI = "";
    string endURI = "";
    uint256 price;

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
    uint256 cap = 3200;

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
        uint256 _tokenId,
        address _to
    ) public payable {
        if (_mode == 0) {
            require(approved[msg.sender], "msg.sender is not approved");
            evolve(_evo, _tokenId, _to);
        } else if (_mode == 1) {
            require(msg.value >= price * _amount, "Price not paid");
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
            require(bannerId + _amount <= beastId, "");
            for (uint256 x; x < _amount; x++) {
                bannerId++;
                _safeMint(_to, bannerId);
                _setTokenURI(
                    bannerId,
                    string(
                        abi.encodePacked(startURI, bannerId.toString(), endURI)
                    )
                );

                if (_lastRound) {
                    mintedInLastRoundTokens.push(bannerId);
                }
            }
        } else if (_evo == 1) {
            require(beastId + _amount <= warId);
            for (uint256 x; x < _amount; x++) {
                beastId++;
                _safeMint(_to, beastId);
                _setTokenURI(
                    beastId,
                    string(
                        abi.encodePacked(startURI, beastId.toString(), endURI)
                    )
                );
            }
        } else if (_evo == 2) {
            require(warId + _amount <= battleId);
            for (uint256 x; x < _amount; x++) {
                warId++;
                _safeMint(_to, warId);
                _setTokenURI(
                    warId,
                    string(abi.encodePacked(startURI, warId.toString(), endURI))
                );
            }
        } else if (_evo == 3) {
            require(battleId + _amount <= valhallaId);
            for (uint256 x; x < _amount; x++) {
                battleId++;
                _safeMint(_to, battleId);
                _setTokenURI(
                    battleId,
                    string(
                        abi.encodePacked(startURI, battleId.toString(), endURI)
                    )
                );
            }
        } else if (_evo == 4) {
            require(valhallaId + _amount <= cap);
            for (uint256 x; x < _amount; x++) {
                valhallaId++;
                _safeMint(_to, valhallaId);
                _setTokenURI(
                    valhallaId,
                    string(
                        abi.encodePacked(
                            startURI,
                            valhallaId.toString(),
                            endURI
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
     * @notice set info about uris and price
     * @param _startURI => start of the token uri
     * @param _endURI => end of the token uri
     * @param _price => price per token * (10**18)
     */
    function setHulkiInfo(
        string memory _startURI,
        string memory _endURI,
        uint256 _price
    ) public onlyOwner {
        startURI = _startURI;
        endURI = _endURI;
        price = _price;
    }

    /**
     * @notice set minting round, 0 to 4 (1 to 5)
     * @param _round => 0 to 4 (1 to 5)
     */
    function setRound(uint8 _round) public onlyOwner {
        require(_round <= 4, "Wrong round");
        round = _round;
    }

    /**
     * @notice needed for staking
     * @return mintedInLastRoundTokens => tokens minted in round 3 (4) */
    function getTokenIdsMintedInLastRound()
        public
        view
        returns (uint256[] memory)
    {
        return mintedInLastRoundTokens;
    }

    /**
    * @notice see {ERC721Metadata} */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return string(abi.encodePacked(startURI, tokenId.toString(), endURI));
    }
}
