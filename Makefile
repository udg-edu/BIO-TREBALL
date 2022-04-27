RMD2HTML=run-knit2html.R

ID_GROUP = $(shell cat udg_codis_grup.txt)
ID_CORRECTOR = $(shell cat udg_codis_correctors.txt)
ID_TREBALLS = $(shell cat codis_treballs.txt)

DADES = $(foreach id_group,$(ID_GROUP),$(shell printf '04-dades_aleatori/%s.RData' $(id_group))) 

DOCS = $(foreach id_group,$(ID_GROUP),$(shell printf '05-enunciat/enunciat1_%s.pdf' $(id_group)))

SOLS = $(foreach id_group,$(ID_TREBALLS),$(shell printf '08-solucio/solucio1_%s.pdf' $(id_group)))

CORR = $(foreach id_group,$(ID_CORRECTOR),$(shell printf '09-enunciat_correccio/enunciat_cor1_%s.pdf' $(id_group)))

all: 03-dades.RData $(DADES) $(DOCS) $(SOLS) $(CORR)

#  $(DOCS_TEMP)

dades/diamants-SEED_%.RData : build_data.R
	Rscript -e 'SEED = $*; source("$<")'

03-dades.RData : 03-dades.R
	Rscript $<

04-dades_aleatori/%.RData : 04-dades_aleatori.R 03-dades.RData
	Rscript -e '.ID = "$*"; source("$<")'

05-enunciat/enunciat1_%.pdf : 05-enunciat.Rmd 04-dades_aleatori/%.RData 
	Rscript -e '.ID = "$*"; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'

08-solucio/solucio1_%.pdf : 08-solucio.Rmd 04-dades_aleatori/%.RData 
	Rscript -e '.ID = "$*"; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'

09-enunciat_correccio/enunciat_cor1_%.pdf : 09-enunciat_correccio.Rmd 07-correccio.RData
	Rscript -e '.ID = "$*"; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'

docs/enunciat_%.html : treball_estadistica.Rmd dades/diamants-SEED_%.RData
	Rscript -e 'SEED = $*; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'



docs/solucio_%.pdf : treball_estadistica_solucio.Rmd dades/diamants-SEED_%.RData
	Rscript -e 'SEED = $*; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'

docs_temp/correccio_%.html : treball_estadistica_correccio.Rmd
	Rscript -e 'UDG_ID = "$*"; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'
	
