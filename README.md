# MiniDemographicABM.jl 
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

### Title 
MiniDemographicABM.jl: A simplified agent based model of UK demography based on the Agents.jl Julia package   

### Description

This package implements of a simplified non-calibrated agent-based demographic model of the UK. Individuals of an initial population are subject to ageing, deaths, births, divorces and marriages. The main purpose of the model is to explore and exploit capabilities of the state-of-the-art Agents.jl Julia package. Additionally, the model can serve as a base model to be adjusted to realistic large-scale socio-economics, pandemics or social interactions-based studies mainly within a demographic context. A specific case-study simulation is progressed with a user-defined simulation fixed step size on a hourly, daily, weakly, monthly basis or even an arbitrary user-defined clock rate.  

### Author(s) 
Atiyah Elsheikh 

### Contributor(s)  
Atiyah Elsheikh (V1.0)  

### Release Notes 
- **V1.0** (22.2.2023) : First initial implementation exploring various capabilities of Agents.jl as a demonstration of how to implement an abstract demographic ABM, not yet calibrated. A space type was implemented as a demonstration. A comprehensive set of unit tests is included. Blue style coding convetions are followed. 
    - V1.0.1 (14.7.23) : updating ReadMe with usually demanded information 

### License
MIT License

Copyright (c) 2023 Atiyah Elsheikh, MRC/CSO Social & Public Health Sciences Unit, School of Health and Wellbeing, University of Glasgow, Cf. [License](https://github.com/MRC-CSO-SPHSU/MiniDemographicABM.jl/blob/master/LICENSE) for further information

### Platform 
This code was developed and experimented on 
- Ubuntu 22.04.2 LTS
- VSCode V1.71.2
- Julia language V1.9.1
- Agents.jl V5.14.0

### URL 
Check for updates here: 
- **V1.0** at least till 10.07.2023: [MiniDemographicABM.jl](https://github.com/MRC-CSO-SPHSU/MiniDemographicABM.jl)

### Exeution 
Within Shell:

`$ julia <script-name.jl>`

Within REPL: 

`> include <script-name.jl>`

where script names are 
- main.jl : for executing the simulation program
- runalltests.jl: for running unit tests. 

### References
The underlying model is inspired by the model given in the following paper:   

[1] Umberto Gostoli and Eric Silverman Social and child care provision in kinship networks: An agent-based model. PLoS ONE 15(12): 2020 (https://doi.org/10.1371/journal.pone.0242779)

The packages Agents.jl: 

[2] George Datseris, Ali R. Vahdati, Timothy C. DuBois: Agents.jl: a performant and feature-full agent-based modeling software of minimal code complexity. SIMULATION. 2022. doi:10.1177/00375497211068820

### Acknowledgements  
- [Dr. Martin Hinsch](https://www.gla.ac.uk/schools/healthwellbeing/staff/martinhinsch/) for Scientific Exchange
- [Dr. Eric Silverman](https://www.gla.ac.uk/schools/healthwellbeing/staff/ericsilverman/) Principle Invistigator 

For the purpose of open access, the author(s) has applied a Creative Commons Attribution (CC BY) licence to any Author Accepted Manuscript version arising from this submission.

### Fundings 
[Dr. Atyiah Elsheikh](https://www.gla.ac.uk/schools/healthwellbeing/staff/atiyahelsheikh/), by the time of publishing Version 1.0 of this software, is a Research Software Engineer at MRC/CSO Social & Public Health Sciences Unit, School of Health and Wellbeing, University of Glasgow. He is in the Complexity in Health programme. He is supported  by the Medical Research Council (MC_UU_00022/1) and the Scottish Government Chief Scientist Office (SPHSU16). 
