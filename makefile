
# run_script_interaction:
# 	SEPOLIA_RPC_URL=$(shell grep SEPOLIA_RPC_URL .env | cut -d '=' -f2) \
# 	PRIVATE_KEY=$(shell grep PRIVATE_KEY .env | cut -d '=' -f2) \
# 	forge script script/interactions.s.sol --rpc-url $$SEPOLIA_RPC_URL --private-key $$PRIVATE_KEY --broadcast



# run_script_interaction:
# 	@SEPOLIA_RPC_URL=$(shell grep SEPOLIA_RPC_URL .env | cut -d '=' -f2) \
# 	PRIVATE_KEY=$(shell grep PRIVATE_KEY .env | cut -d '=' -f2) \
# 	forge script script/interactions.s.sol --rpc-url $$SEPOLIA_RPC_URL --private-key $$PRIVATE_KEY --broadcast > /dev/null 2>&1

run_script_interaction:
	@SEPOLIA_RPC_URL=$(shell grep SEPOLIA_RPC_URL .env | cut -d '=' -f2) \
	PRIVATE_KEY=$(shell grep PRIVATE_KEY .env | cut -d '=' -f2) \
	forge script script/interactions.s.sol:LogStuff --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --ffi
	forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast

