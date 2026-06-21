{
  nix.linux-builder = {
    enable = true;
    systems = [ "aarch64-linux" ];

    # Force software emulation (TCG) instead of hardware acceleration (HVF).
    #
    # QEMU 11.0.x's HVF backend aborts at VM init on macOS 26 (Tahoe):
    #   hvf_arch_init_vcpu: assertion failed (HV_SYS_REG_SMCR_EL1 == KVMID_TO_HVF(...))
    # Tahoe added the SME SMCR_EL1 register to Hypervisor.framework's enum and
    # QEMU 11.0.x asserts on the ordering, SIGABRTing instead of falling back to
    # the `:tcg` alternative baked into the default `-machine accel=hvf:tcg`.
    # Appending `-machine accel=tcg` overrides that (last value wins), so the
    # builder boots — slower, but functional.
    #
    # TODO: Remove this override once nixpkgs ships QEMU >= 11.1.x with the HVF
    # SMCR_EL1 fix; HVF acceleration is far faster than TCG. Track qemu version
    # with: nix eval --raw github:nixos/nixpkgs/nixos-unstable#qemu.version
    config = {
      virtualisation.qemu.options = [ "-machine accel=tcg" ];
    };
  };
}
