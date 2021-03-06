version 1.0

workflow SimpleVariantDiscovery {
    input {
        File gatk
        File refFasta
        File refIndex
        File refDict
        String sampleName
        File inputBam
        File bamIndex
        File testando
    }

    call HaplotypeCaller {
        input:
            gatk = gatk,
            refFasta = refFasta,
            refIndex = refIndex,
            refDict = refDict,
            sampleName = sampleName,
            inputBam = inputBam,
            bamIndex = bamIndex
    }

    call SimpleVariantSelection as selectSNPs { 
        input:
            gatk = gatk,
            refFasta = refFasta,
            refIndex = refIndex,
            refDict = refDict,
            sampleName = sampleName,
            type = "SNP", 
                rawVcf = testando
    }
    
    call SimpleVariantSelection as selectIndels { 
        input:
            gatk = gatk,
            refFasta = refFasta,
            refIndex = refIndex,
            refDict = refDict,
            sampleName = sampleName,
            type = "INDEL", 
                rawVcf = testando 
    }

    call HardFilterSNP {
        input:
            sampleName = sampleName, 
            refFasta = refFasta, 
            gatk = gatk, 
            refIndex = refIndex, 
            refDict = refDict, 
            rawSNPs = selectSNPs.rawSubset
    }
    
    call HardFilterIndel {
        input:
            sampleName = sampleName, 
            refFasta = refFasta, 
            gatk = gatk, 
            refIndex = refIndex, 
            refDict = refDict,
            rawIndels = selectIndels.rawSubset
    }
    
    call Combine {
        input:
            sampleName = sampleName, 
            refFasta = refFasta, 
            gatk = gatk, 
            refIndex = refIndex, 
            refDict = refDict,
            filteredSNPs = HardFilterSNP.filteredSNPs, 
            filteredIndels = HardFilterIndel.filteredIndels
    }
}

task HaplotypeCaller {
    input {
        File gatk
        File refFasta
        File refIndex
        File refDict
        String sampleName
        File inputBam
        File bamIndex
    }

    command <<<
        java -jar ~{gatk} \
            HaplotypeCaller \
            -R ~{refFasta} \
            -I ~{inputBam} \
            -O ~{sampleName}.raw.indels.snps.vcf
    >>>

    output {
        File rawVcf = "~{sampleName}.raw.indels.snps.vcf"
    }
    
    parameter_meta {
        refFasta: "Reference fasta file"
        inputBam: "Bam file"
        rawVcf: "VCF file"
    }
}

task SimpleVariantSelection {
    input {
        File gatk
        File refFasta
        File refIndex
        File refDict
        String sampleName
        String type
        File rawVcf
    }

    command <<<
        java -jar ~{gatk} \
            SelectVariants \
            -R ~{refFasta} \
            -V ~{rawVcf} \
            -select-type ~{type} \
            -O ~{sampleName}_raw.~{type}.vcf
    >>>

    output {
        File rawSubset = "~{sampleName}_raw.~{type}.vcf"
    }
    
    parameter_meta {
        refFasta: "Reference fasta file"
        rawVcf: "VCF file"
        type: "Select only a certain type of variants from the input file"
        rawSubset: "Raw subset file"
    }
}

task HardFilterSNP {
    input {
        File gatk
        File refFasta
        File refIndex
        File refDict
        String sampleName
        File rawSNPs
    }

    command <<<
        java -jar ~{gatk} \
            VariantFiltration \
            -R ~{refFasta} \
            -V ~{rawSNPs} \
            --filter-expression "FS > 60.0" \
            --filter-name "snp_filter" \
            -O ~{sampleName}.filtered.snps.vcf
    >>>

    output {
        File filteredSNPs = "~{sampleName}.filtered.snps.vcf"
    }
    
    parameter_meta {
        refFasta: "Reference fasta file"
        rawSNP: "SNP file"
        filterExpression: "String, One or more expressions used with INFO fields to filter"
        filterName: "String, Names to use for the list of filters"
        filteredSNPs: "Filtered SNP file"
    }
}

task HardFilterIndel {
    input {
        File gatk
        File refFasta
        File refIndex
        File refDict
        String sampleName
        File rawIndels
    }

    command <<<
        java -jar ~{gatk} \
            VariantFiltration \
            -R ~{refFasta} \
            -V ~{rawIndels} \
            --filter-expression "FS > 200.0" \
            --filter-name "indel_filter" \
            -O ~{sampleName}.filtered.indels.vcf
    >>>

    output {
        File filteredIndels = "~{sampleName}.filtered.indels.vcf"
    }
    
    parameter_meta {
        refFasta: "Reference fasta file"
        rawSNP: "SNP file"
        filterExpression: "String, One or more expressions used with INFO fields to filter"
        filterName: "String, Names to use for the list of filters"
        filteredIndels: "Filtered indel file"
    }
}

task Combine {
    input {
        File gatk
        File refFasta
        File refIndex
        File refDict
        String sampleName
        File filteredSNPs
        File filteredIndels
    }
    
    command <<<
        java -jar ~{gatk} \
            MergeVcfs \
            -R ~{refFasta} \
            -I ~{filteredSNPs} \
            -I ~{filteredIndels} \
            -O ~{sampleName}.filtered.snps.indels.vcf
    >>>

    output {
        File filteredVCF = "~{sampleName}.filtered.snps.indels.vcf"
    }
    
    parameter_meta {
        refFasta: "Reference fasta file"
        filteredSNPs: "Filtered SNP file"
        filteredIndels: "Filtered Indel file"
        filteredVCF: "Filtered VCF file"
    }
}
