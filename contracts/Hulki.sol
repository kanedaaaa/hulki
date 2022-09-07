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
        Counters.Counter bannerID;
        Counters.Counter beastID;
        Counters.Counter warID;
        Counters.Counter battleID;
        Counters.Counter valhallaID;
        uint256 bannerTS;
        uint256 beastTS;
        uint256 warTS;
        uint256 battleTS;
        uint256 valhallaTS;
    }

    struct MultiPack {
        uint256 bannerPack;
        uint256 beastPack;
        uint256 warPack;
        uint256 battlePack;
        uint256 valhallaPack;
    }

    /** @notice token uris, counters and supply */
    HulkiInfo hulkiInfo;
    /** @notice total supply of each multi pack */
    MultiPack multiPack;
    /** @notice approved managers, such as staking contract */
    mapping(address => bool) public approved;

    constructor() ERC721("Hulki", "H") {
        approved[msg.sender] = true;
    }

    /**
    * @notice public mint function
    * @param _mode => 0.called from staking contract
    * 1.multipack mint
    * @param _evo => evolution of nft
    * @param _multiPack => if _mode 1 was chosen, then 
    * this param will handle which multipack to mint.
     */
    function mint(uint8 _mode, uint8 _evo, uint8 _multiPack) public {
        if (_mode == 0) {
            // staking mint
            require(approved[msg.sender], "msg.sender is not approved");
            _lowMint(_evo, 1);
        } else if (_mode == 1) {
            // multipack mint
            if (_multiPack == 0) {
                _lowMint(0, multiPack.bannerPack);
            } else if (_multiPack == 1) {
                _lowMint(1, multiPack.beastPack);
            } else if (_multiPack == 2) {
                _lowMint(2, multiPack.warPack);
            } else if (_multiPack == 3) {
                _lowMint(3, multiPack.battlePack);
            } else if (_multiPack == 4) {
                _lowMint(4, multiPack.valhallaPack);
            }
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
    function _lowMint(uint8 _evo, uint256 _amount) internal {
        if (_evo == 0) {
            require(
                hulkiInfo.bannerID.current() + _amount <= hulkiInfo.bannerTS
            );
            for (uint256 x; x < _amount; x++) {
                hulkiInfo.bannerID.increment();
                _safeMint(msg.sender, hulkiInfo.bannerID.current());
                _setTokenURI(
                    hulkiInfo.bannerID.current(),
                    string(
                        abi.encodePacked(
                            hulkiInfo.bannerURI,
                            hulkiInfo.bannerID.current().toString(),
                            ".json"
                        )
                    )
                );
            }
        } else if (_evo == 1) {
            require(hulkiInfo.beastID.current() + _amount <= hulkiInfo.beastTS);
            for (uint256 x; x < _amount; x++) {
                hulkiInfo.beastID.increment();
                _safeMint(msg.sender, hulkiInfo.beastID.current());
                _setTokenURI(
                    hulkiInfo.beastID.current(),
                    string(
                        abi.encodePacked(
                            hulkiInfo.beastURI,
                            hulkiInfo.beastID.current().toString(),
                            ".json"
                        )
                    )
                );
            }
        } else if (_evo == 2) {
            require(hulkiInfo.warID.current() + _amount <= hulkiInfo.warTS);
            for (uint256 x; x < _amount; x++) {
                hulkiInfo.warID.increment();
                _safeMint(msg.sender, hulkiInfo.warID.current());
                _setTokenURI(
                    hulkiInfo.warID.current(),
                    string(
                        abi.encodePacked(
                            hulkiInfo.warURI,
                            hulkiInfo.warID.current().toString(),
                            ".json"
                        )
                    )
                );
            }
        } else if (_evo == 3) {
            require(
                hulkiInfo.battleID.current() + _amount <= hulkiInfo.battleTS
            );
            for (uint256 x; x < _amount; x++) {
                hulkiInfo.battleID.increment();
                _safeMint(msg.sender, hulkiInfo.battleID.current());
                _setTokenURI(
                    hulkiInfo.battleID.current(),
                    string(
                        abi.encodePacked(
                            hulkiInfo.battleURI,
                            hulkiInfo.battleID.current().toString(),
                            ".json"
                        )
                    )
                );
            }
        } else if (_evo == 4) {
            require(
                hulkiInfo.valhallaID.current() + _amount <= hulkiInfo.valhallaTS
            );
            for (uint256 x; x < _amount; x++) {
                hulkiInfo.valhallaID.increment();
                _safeMint(msg.sender, hulkiInfo.valhallaID.current());
                _setTokenURI(
                    hulkiInfo.valhallaID.current(),
                    string(
                        abi.encodePacked(
                            hulkiInfo.valhallaURI,
                            hulkiInfo.valhallaID.current().toString(),
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
}
