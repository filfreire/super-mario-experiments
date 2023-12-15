# super-mario-experiments

metaheuristics experiments on super mario bros

## Setup

> Note: tested using Windows 10 Pro 22H2

- Install [FCEUX](https://github.com/TASEmulators/fceux) (tested with win32 version)
- Load Rom (e.g. SMB USA rom)
- Try to run one of the example-scripts on fceux, alternatively run `./example-run.ps1` powershell script.

### Extra setup steps

- Add `fceux` to the `PATH` in order to run it directly. For command line options see <https://fceux.com/web/help/CommandLineOptions.html>
- Install `lua` (e.g. <https://github.com/rjpcomputing/luaforwindows/releases>)
- Copy `iuplua51.dll` and `lfs.dll` from your Lua install directory into root of `fceux` installation directory

## Resources

- FCEUX lua scripting <https://fceux.com/web/help/LuaScripting.html>
- Super Mario Bros RAM map <https://datacrystal.romhacking.net/wiki/Super_Mario_Bros.:RAM_map>
- <https://github.com/NesHacker/PlatformerMovement/>
- <https://www.youtube.com/watch?v=ZuKIUjw_tNU>
- <https://github.com/mam91/Neat-Genetic-Mario>

## Other sources

> Leane, M., & Noman, N. (2017, November). An evolutionary metaheuristic algorithm to optimise solutions to NES games. In 2017 21st Asia Pacific Symposium on Intelligent and Evolutionary Systems (IES) (pp. 19-24). IEEE.
>
> Aloupis, G., Demaine, E. D., Guo, A., & Viglietta, G. (2015). Classic Nintendo games are (computationally) hard. Theoretical Computer Science, 586, 135-160.
>
> Gabrielsen, C. (2012). Video Game Motion Planning reviewed NP-complete.
