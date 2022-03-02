version 1.0

workflow Tutorial_2 {
    input {
        File GATK
        File RefFasta
        File RefIndex
        File RefDict
        String sampleName
        File inputBAM
        File bamIndex
        File Testando
    }

    call HaplotypeCaller {
        input:
            GATK = GATK,
            RefFasta = RefFasta,
            RefIndex = RefIndex,
            RefDict = RefDict,
            sampleName = sampleName,
            inputBAM = inputBAM,
            bamIndex = bamIndex
    }

    call SimpleVariantSelection as selectSNPs { 
        input:
            GATK = GATK,
            RefFasta = RefFasta,
            RefIndex = RefIndex,
            RefDict = RefDict,
            sampleName = sampleName,
            type = "SNP", 
                rawVCF = Testando
    }
    
    call SimpleVariantSelection as selectIndels { 
        input:
            GATK = GATK,
            RefFasta = RefFasta,
            RefIndex = RefIndex,
            RefDict = RefDict,
            sampleName = sampleName,
            type = "INDEL", 
                rawVCF = Testando 
    }
}

task HaplotypeCaller {
    input {
        File GATK
        File RefFasta
        File RefIndex
        File RefDict
        String sampleName
        File inputBAM
        File bamIndex
    }

    command {
        java -jar ${GATK} \
            HaplotypeCaller \
            -R ${RefFasta} \
            -I ${inputBAM} \
            -O ${sampleName}.raw.indels.snps.vcf
    }

    output {
        File rawVCF = "${sampleName}.raw.indels.snps.vcf"
    }
}

task SimpleVariantSelection {
    input {
        File GATK
        File RefFasta
        File RefIndex
        File RefDict
        String sampleName
        String type
        File rawVCF
    }

    command {
        java -jar ${GATK} \
            SelectVariants \
            -R ${RefFasta} \
            -V ${rawVCF} \
            -select-type ${type} \
            -O ${sampleName}_raw.${type}.vcf
  }
    output {
        File rawSubset = "${sampleName}_raw.${type}.vcf"
  }
}

##apenas um comentário para fazer mudançaaas