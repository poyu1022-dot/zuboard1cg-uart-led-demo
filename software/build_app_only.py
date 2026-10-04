# Lightweight rebuild: recompiles only the hello_avnet application against an
# ALREADY-BUILT platform (see build_platform_and_app.py for the one-time,
# heavier platform build). Use this for day-to-day changes such as editing
# the printed message in helloworld.c.
#
#   vitis -s software/build_app_only.py
#
# Output ELF: <workspace>/hello_avnet/build/hello_avnet.elf

import os
import vitis

script_dir = os.path.dirname(os.path.abspath(__file__))
workspace = os.path.join(script_dir, "vitis_ws_build")

client = vitis.create_client()
try:
    client.set_workspace(path=workspace)
except Exception:
    client.update_workspace(path=workspace)

app = client.get_component(name="hello_avnet")
app.build()

print("BUILD_DONE:", os.path.join(workspace, "hello_avnet", "build", "hello_avnet.elf"))
