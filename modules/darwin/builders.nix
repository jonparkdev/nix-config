{
  nix.linux-builder = {
    enable = true;
    systems = [ "aarch64-linux" ];

    config = {
      # ── Force software emulation (TCG) ──────────────────────────────────────
      # QEMU 11.0.x's HVF backend aborts at VM init on macOS 26 (Tahoe):
      #   hvf_arch_init_vcpu: assertion failed (HV_SYS_REG_SMCR_EL1 == KVMID_TO_HVF(...))
      # macOS 26 added the SME SMCR_EL1 register to Hypervisor.framework's enum
      # and QEMU 11.0.x asserts on the ordering, SIGABRTing rather than falling
      # back to the `:tcg` alternative in the default `-machine accel=hvf:tcg`.
      # There is no CPU-flag escape (SME can't be disabled on `-cpu host`), and
      # neither the full `qemu` nor `qemu-host-cpu-only` build avoids it. So we
      # pin the accelerator to TCG until QEMU ships the macOS-26 HVF fix.
      #
      # TODO: Drop this `-machine accel=tcg` override and the cores/memory bump
      # below once nixpkgs' QEMU runs under HVF on macOS 26 (re-test by removing
      # the override and checking the builder boots without the SMCR_EL1 abort).
      virtualisation.qemu.options = [ "-machine accel=tcg" ];

      # ── Make TCG bearable: more vCPUs + RAM ─────────────────────────────────
      # TCG is software emulation, so it's slow — but multi-threaded TCG runs
      # each guest vCPU on its own host thread, giving the guest real `make -j`
      # parallelism. Building the rpi kernel went from "days on 1 core" to a few
      # hours with these. Host is an M1 Pro (8 cores / 32 GB); we leave headroom.
      virtualisation.cores = 6;
      virtualisation.darwin-builder.memorySize = 12 * 1024; # 12 GiB
    };
  };
}
