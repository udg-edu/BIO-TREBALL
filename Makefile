RMD2HTML=run-knit2html.R

ID_GROUP = $(shell cat udg_codis_grup.txt)
ID_CORRECTOR = $(shell cat udg_codis_correctors.txt)
ID_TREBALLS = $(shell cat codis_treballs.txt)

ID_GROUP2 = $(shell cat udg_codis_grup.txt)
ID_CORRECTOR2 = $(shell cat udg_codis_correctors_B.txt)
ID_TREBALLS2 = $(shell cat codis_treballs_B.txt)

DADES = $(foreach id_group,$(ID_GROUP),$(shell printf '04-dades_aleatori/%s.RData' $(id_group))) 
DOCS = $(foreach id_group,$(ID_GROUP),$(shell printf '05-enunciat/enunciat1_%s.pdf' $(id_group)))
SOLS = $(foreach id_group,$(ID_GROUP),$(shell printf '08-solucio/solucio1_%s.pdf' $(id_group)))

CORR = $(foreach id_group,$(ID_CORRECTOR),$(shell printf '09-enunciat_correccio/enunciat_cor1_%s.html' $(id_group)))

SOLS2 = $(foreach id_group,$(ID_TREBALLS2),$(shell printf '08B-solucio/solucio2_%s.pdf' $(id_group)))
DOCS2 = $(foreach id_group,$(ID_GROUP2),$(shell printf '05b-enunciat/enunciat2_%s.pdf' $(id_group)))
DADES2 = $(foreach id_group,$(ID_GROUP2),$(shell printf '04B-dades_aleatori/%s.RData' $(id_group))) 
CORR2 = $(foreach id_group,$(ID_CORRECTOR2),$(shell printf '09B-enunciat_correccio/enunciat_cor2_%s.html' $(id_group)))

all: 03-dades.RData \
     $(DADES) $(DOCS) $(SOLS) $(CORR) $(DOCS2) $(SOLS2) $(CORR2) # $(DADES2)   

#  $(DOCS_TEMP)

dades/diamants-SEED_%.RData : build_data.R
	Rscript -e 'SEED = $*; source("$<")'

03-dades.RData : 03-dades.R
	Rscript $<

04-dades_aleatori/%.RData : 04-dades_aleatori.R 03-dades.RData
	Rscript -e '.ID = "$*"; source("$<")'

04B-dades_aleatori/%.RData : 04B-dades_aleatori.R 04-dades_aleatori/%.RData
	Rscript -e '.ID = "$*"; source("$<")'

05-enunciat/enunciat1_%.pdf : 05-enunciat.Rmd 04-dades_aleatori/%.RData 
	Rscript -e '.ID = "$*"; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'

05b-enunciat/enunciat2_%.pdf : 05B-enunciat.Rmd 04-dades_aleatori/%.RData 
	Rscript -e '.ID = "$*"; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'

08-solucio/solucio1_%.pdf : 08-solucio.Rmd 04-dades_aleatori/%.RData 
	Rscript -e '.ID = "$*"; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'

08B-solucio/solucio2_%.pdf : 08B-solucio.Rmd 04-dades_aleatori/%.RData 
	Rscript -e '.ID = "$*"; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'

09-enunciat_correccio/enunciat_cor1_%.html : 09-enunciat_correccio.Rmd 
	Rscript -e '.ID = "$*"; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'

09B-enunciat_correccio/enunciat_cor2_%.html : 09B-enunciat_correccio.Rmd 
	Rscript -e '.ID = "$*"; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'

docs/enunciat_%.html : treball_estadistica.Rmd dades/diamants-SEED_%.RData
	Rscript -e 'SEED = $*; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'



docs/solucio_%.pdf : treball_estadistica_solucio.Rmd dades/diamants-SEED_%.RData
	Rscript -e 'SEED = $*; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'

docs_temp/correccio_%.html : treball_estadistica_correccio.Rmd
	Rscript -e 'UDG_ID = "$*"; IN = "$<"; OUT = "$@"; source("$(RMD2HTML)")'
	
