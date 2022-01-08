// contracts/lib/BANGModule.sol
// SPDX-License-Identifier: SUDO
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "./interfaces/IBANG.sol";

abstract contract BANGModule is ContextUpgradeable {
    IBANG internal bang;

    function __BANGModule_init(address _bang) internal initializer {
        __Context_init();
        __BANGModule_init_unchained(_bang);
    }

    function __BANGModule_init_unchained(address _bang) internal initializer {
        bang = IBANG(_bang);
    }
}
