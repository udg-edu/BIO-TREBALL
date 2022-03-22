RMD2HTML=run-knit2html.R

ID_GROUP = $(shell cat udg_codis_grup.txt)
ID_CORRECTOR = $(shell cat udg_codis_correctors.txt)

DADES = $(foreach id_group,$(ID_GROUP),$(shell printf '04-dades_aleatori/%s.RData' $(id_group))) 

DOCS = $(foreach id_group,$(ID_GROUP),$(shell printf '05-enunciat/enunciat1_%s.pdf' $(id_group)))

DOCS_TEMP = $(foreach id_corrector,$(ID_CORRECTOR),$(shell printf 'docs_temp/correccio_%s.html' $(id_corrector))) 

all: 03-dades.RData $(DADES) $(DOCS)

#  $(DOCS_TEMP)

dades/diamants-SEED_%.RData : build_data.R
	Rscript -e 'SEED = $*; source("$<")'

03-dades.RData : 03-dades.R
	Rscript $<

04-dades_aleatori/%.RData : 04-dades_aleatori.R 03-dades.RData
	Rscript -e '.ID = "$*"; source("$<")'

05-enunciat/enunciat1_%.pdf : 05-enunciat.Rmd 04-dades_aleatori/%.RData 
	Rscript -e '.ID = "$*"; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'

docs/enunciat_%.html : treball_estadistica.Rmd dades/diamants-SEED_%.RData
	Rscript -e 'SEED = $*; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'



docs/solucio_%.pdf : treball_estadistica_solucio.Rmd dades/diamants-SEED_%.RData
	Rscript -e 'SEED = $*; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'

docs_temp/correccio_%.html : treball_estadistica_correccio.Rmd
	Rscript -e 'UDG_ID = "$*"; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'
	
