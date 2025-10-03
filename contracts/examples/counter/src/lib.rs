#![no_std]

multiversx_sc::imports!();

#[multiversx_sc::contract]
pub trait Counter {
    #[init]
    fn init(&self) {
        self.counter().set(0);
    }

    #[upgrade]
    fn upgrade(&self) {}

    #[endpoint]
    fn increment(&self) {
        self.counter().update(|c| *c += 1);
    }

    #[endpoint]
    fn decrement(&self) {
        self.counter().update(|c| *c -= 1);
    }

    #[view(get)]
    #[storage_mapper("counter")]
    fn counter(&self) -> SingleValueMapper<u64>;
}
