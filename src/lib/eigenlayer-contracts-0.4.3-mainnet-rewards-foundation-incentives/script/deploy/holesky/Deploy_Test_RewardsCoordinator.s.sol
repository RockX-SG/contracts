// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.12;

import "../../utils/ExistingDeploymentParser.sol";

/**
 * @notice Script used for the first deployment of EigenLayer core contracts to Holesky
 * anvil --fork-url $RPC_HOLESKY
 * forge script script/deploy/holesky/Deploy_Test_RewardsCoordinator.s.sol --rpc-url http://127.0.0.1:8545 --private-key $PRIVATE_KEY --broadcast -vvvv
 * forge script script/deploy/holesky/Deploy_Test_RewardsCoordinator.s.sol --rpc-url $RPC_HOLESKY --private-key $PRIVATE_KEY --verify --broadcast -vvvv
 *
 */
contract Deploy_Test_RewardsCoordinator is ExistingDeploymentParser {

    address testAddress = 0xDA29BB71669f46F2a779b4b62f03644A84eE3479;
    address initOwner = 0xDA29BB71669f46F2a779b4b62f03644A84eE3479;

    function run() external virtual {
        _parseInitialDeploymentParams("script/configs/holesky/eigenlayer_testnet.config.json");
        _parseDeployedContracts("script/configs/holesky/eigenlayer_addresses.config.json");

        // START RECORDING TRANSACTIONS FOR DEPLOYMENT
        vm.startBroadcast();

        emit log_named_address("Deployer Address", msg.sender);

        _deployImplementation();

        // STOP RECORDING TRANSACTIONS FOR DEPLOYMENT
        vm.stopBroadcast();

        // Sanity Checks
        _verifyContractPointers();
        _verifyImplementations();
        _verifyContractsInitialized(true);
        _verifyInitializationParams();

        logAndOutputContractAddresses("script/output/holesky/Deploy_RewardsCoordinator.holesky.config.json");
    }

    /**
     * @notice Deploy RewardsCoordinator for Holesky
     */
    function _deployRewardsCoordinator() internal {
        // Deploy RewardsCoordinator proxy and implementation
        rewardsCoordinatorImplementation = new RewardsCoordinator(
            delegationManager,
            strategyManager,
            REWARDS_COORDINATOR_CALCULATION_INTERVAL_SECONDS,
            REWARDS_COORDINATOR_MAX_REWARDS_DURATION,
            REWARDS_COORDINATOR_MAX_RETROACTIVE_LENGTH,
            REWARDS_COORDINATOR_MAX_FUTURE_LENGTH,
            REWARDS_COORDINATOR_GENESIS_REWARDS_TIMESTAMP
        );
        rewardsCoordinator = RewardsCoordinator(
            address(
                new TransparentUpgradeableProxy(
                    address(rewardsCoordinatorImplementation),
                    address(eigenLayerProxyAdmin),
                    abi.encodeWithSelector(
                        RewardsCoordinator.initialize.selector,
                        executorMultisig,
                        eigenLayerPauserReg,
                        REWARDS_COORDINATOR_INIT_PAUSED_STATUS,
                        REWARDS_COORDINATOR_UPDATER,
                        REWARDS_COORDINATOR_ACTIVATION_DELAY,
                        REWARDS_COORDINATOR_GLOBAL_OPERATOR_COMMISSION_BIPS
                    )
                )
            )
        );
    }

        /**
     * @notice Deploy RewardsCoordinator Implementation for Holesky and upgrade the proxy
     */
    function _upgradeRewardsCoordinator() internal {
        // Deploy RewardsCoordinator proxy and implementation
        rewardsCoordinatorImplementation = new RewardsCoordinator(
            delegationManager,
            strategyManager,
            REWARDS_COORDINATOR_CALCULATION_INTERVAL_SECONDS,
            REWARDS_COORDINATOR_MAX_REWARDS_DURATION,
            REWARDS_COORDINATOR_MAX_RETROACTIVE_LENGTH,
            REWARDS_COORDINATOR_MAX_FUTURE_LENGTH,
            REWARDS_COORDINATOR_GENESIS_REWARDS_TIMESTAMP
        );

        eigenLayerProxyAdmin.upgrade(
            TransparentUpgradeableProxy(payable(address(rewardsCoordinator))),
            address(rewardsCoordinatorImplementation)
        );
    }

    function _deployImplementation() internal {
        // Existing values for current RewardsCoordinator implementationt on holesky
        require(
            REWARDS_COORDINATOR_CALCULATION_INTERVAL_SECONDS == 604800,
            "REWARDS_COORDINATOR_CALCULATION_INTERVAL_SECONDS must be 604800"
        );
        require(
            REWARDS_COORDINATOR_MAX_REWARDS_DURATION == 6048000,
            "REWARDS_COORDINATOR_MAX_REWARDS_DURATION must be 6048000"
        );
        require(
            REWARDS_COORDINATOR_MAX_RETROACTIVE_LENGTH == 7776000,
            "REWARDS_COORDINATOR_MAX_RETROACTIVE_LENGTH must be 7776000"
        );
        require(
            REWARDS_COORDINATOR_MAX_FUTURE_LENGTH == 2592000,
            "REWARDS_COORDINATOR_MAX_FUTURE_LENGTH must be 2592000"
        );
        require(
            REWARDS_COORDINATOR_GENESIS_REWARDS_TIMESTAMP == 1710979200,
            "REWARDS_COORDINATOR_GENESIS_REWARDS_TIMESTAMP must be 1710979200"
        );

        // Deploy RewardsCoordinator implementation
        rewardsCoordinatorImplementation = new RewardsCoordinator(
            delegationManager,
            strategyManager,
            REWARDS_COORDINATOR_CALCULATION_INTERVAL_SECONDS,
            REWARDS_COORDINATOR_MAX_REWARDS_DURATION,
            REWARDS_COORDINATOR_MAX_RETROACTIVE_LENGTH,
            REWARDS_COORDINATOR_MAX_FUTURE_LENGTH,
            REWARDS_COORDINATOR_GENESIS_REWARDS_TIMESTAMP
        );
    }
}
