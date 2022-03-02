version 1.0

workflow HelloHaplotypeCaller {
    input {
        File GATK
        File RefFasta
        File RefIndex
        File RefDict
        String sampleName
        File inputBAM
        File bamIndex
    }
    call HaplotypeCaller{
        input:
            GATK = GATK,
            RefFasta = RefFasta,
            RefIndex = RefIndex,
            RefDict = RefDict,
            sampleName = sampleName,
            inputBAM = inputBAM,
            bamIndex = bamIndex
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