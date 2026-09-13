# Build the Vitis standalone platform (from the .xsa exported by
# hardware/02_build_bitstream.tcl) and the "hello_avnet" bare-metal application.
#
#   vitis -s build_platform_and_app.py
#
# Output ELF: <repo>/software/vitis_ws/hello_avnet/build/hello_avnet.elf

import os
import vitis

script_dir = os.path.dirname(os.path.abspath(__file__))
repo_dir = os.path.normpath(os.path.join(script_dir, ".."))

xsa_path = os.path.join(repo_dir, "prebuilt", "zuboard_uart_led.xsa")
workspace = os.path.join(script_dir, "vitis_ws")

client = vitis.create_client()
client.set_workspace(path=workspace)

platform = client.create_platform_component(name="zuboard_platform", hw_design=xsa_path)
platform.add_domain(name="standalone_psu_cortexa53_0", cpu="psu_cortexa53_0", os="standalone")
platform.build()

xpfm = os.path.join(workspace, "zuboard_platform", "export", "zuboard_platform", "zuboard_platform.xpfm")

app = client.create_app_component(
    name="hello_avnet",
    platform=xpfm,
    domain="standalone_psu_cortexa53_0",
    template="empty_application",
)
app = client.get_component(name="hello_avnet")
app.import_files(from_loc=script_dir, files=["helloworld.c"], dest_dir_in_cmp="src")
app.build()

print("BUILD_DONE:", os.path.join(workspace, "hello_avnet", "build", "hello_avnet.elf"))
