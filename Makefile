-include .env

.DEFAULT_GOAL := help

.PHONY: all help clean remove install update build zkbuild test zktest snapshot format anvil zk-anvil deploy deploy-sepolia deploy-zk deploy-zk-sepolia fund withdraw

help:
	@echo "Available targets:"
	@echo "  make test - Run the tests using forge"
	@echo "  make build - Build the project using forge"
	@echo "  make clean - Clean the project"
	@echo "  make install - Install dependencies"
	@echo "  make update - Update dependencies"
	@echo "  make deploy - Deploy the contract"
	@echo "  make fund - Fund the contract"
	@echo "  make withdraw - Withdraw from the contract"
	@echo "  make anvil - Run anvil local blockchain"
	@echo "  make zk-anvil - Run zkSync local blockchain"

all: clean remove install update build

clean:
	forge clean

remove:
	rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "Remove modules"

install:
	forge install cyfrin/foundry-devops@0.2.2 --no-commit
	forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit
	forge install foundry-rs/forge-std@v1.8.2 --no-commit

update:
	forge update

build:
	forge build

zkbuild:
	forge build --zksync

test:
	forge test

zktest:
	foundryup-zksync && forge test --zksync && foundryup

snapshot:
	forge snapshot

format:
	forge fmt

anvil:
	anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

zk-anvil:
	npx zksync-cli dev start

deploy:
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS)

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --account $(ACCOUNT) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvv

# As of writing, the Alchemy zkSync RPC URL is not working correctly 
deploy-zk:
	forge create src/FundMe.sol:FundMe --rpc-url http://127.0.0.1:8011 --private-key $(DEFAULT_ZKSYNC_LOCAL_KEY) --constructor-args $(shell forge create test/mock/MockV3Aggregator.sol:MockV3Aggregator --rpc-url http://127.0.0.1:8011 --private-key $(DEFAULT_ZKSYNC_LOCAL_KEY) --constructor-args 8 200000000000 --legacy --zksync | grep "Deployed to:" | awk '{print $$3}') --legacy --zksync

deploy-zk-sepolia:
	forge create src/FundMe.sol:FundMe --rpc-url $(ZKSYNC_SEPOLIA_RPC_URL) --account default --constructor-args 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF --legacy --zksync

SENDER_ADDRESS := <sender's address>

fund:
	@forge script script/Interactions.s.sol:FundFundMe --sender $(SENDER_ADDRESS) $(NETWORK_ARGS)

withdraw:
	@forge script script/Interactions.s.sol:WithdrawFundMe --sender $(SENDER_ADDRESS) $(NETWORK_ARGS)
