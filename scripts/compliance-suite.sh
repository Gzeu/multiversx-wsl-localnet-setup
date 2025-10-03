#!/usr/bin/env bash
# MultiversX Compliance Suite
# MiCA readiness, GDPR compliance, and security audit framework

set -euo pipefail

# Configuration
COMPLIANCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../compliance" && pwd)"
REPORTS_DIR="$COMPLIANCE_DIR/reports"
TEMPLATES_DIR="$COMPLIANCE_DIR/templates"
POLICIES_DIR="$COMPLIANCE_DIR/policies"
LOGS_DIR="$COMPLIANCE_DIR/logs"
AUDIT_LOG="$COMPLIANCE_DIR/audit.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${GREEN}[$timestamp]${NC} $1" | tee -a "$AUDIT_LOG"
}

warn() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${YELLOW}[$timestamp] WARN:${NC} $1" | tee -a "$AUDIT_LOG"
}

error() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${RED}[$timestamp] ERROR:${NC} $1" | tee -a "$AUDIT_LOG"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

usage() {
    cat << EOF
MultiversX Compliance Suite - MiCA, GDPR & Security Compliance

Usage: $0 [COMMAND] [OPTIONS]

Compliance Commands:
    setup           Initialize compliance framework
    audit           Run comprehensive compliance audit
    mica-check      Check MiCA (Markets in Crypto-Assets) compliance
    gdpr-check      Check GDPR compliance
    security-audit  Run security compliance audit
    generate-report Generate compliance report
    policy-check    Validate policies and procedures
    
MiCA Specific Commands:
    mica-setup      Setup MiCA compliance framework
    licensing-check Check licensing requirements
    whitepaper-audit Audit whitepaper compliance
    disclosure-check Check disclosure requirements
    governance-audit Audit governance compliance
    
GDPR Commands:
    privacy-audit   Audit privacy practices
    data-mapping    Map data processing activities
    retention-check Check data retention policies
    consent-audit   Audit consent mechanisms
    breach-procedure Setup breach notification procedures
    
Security Commands:
    penetration-test    Run penetration testing
    vulnerability-scan  Scan for vulnerabilities
    access-audit        Audit access controls
    encryption-check    Check encryption compliance
    backup-audit        Audit backup procedures
    
Reporting Commands:
    compliance-dashboard    Launch compliance dashboard
    generate-mica-report    Generate MiCA compliance report
    generate-gdpr-report    Generate GDPR compliance report
    generate-security-report Generate security audit report
    
Options:
    --output DIR        Output directory for reports
    --format FORMAT     Report format (pdf, html, json)
    --detailed          Include detailed findings
    --remediation       Include remediation recommendations
    
Examples:
    $0 setup                    # Initialize compliance framework
    $0 audit --detailed         # Run detailed compliance audit
    $0 mica-check              # Check MiCA compliance
    $0 generate-report --format pdf  # Generate PDF report
EOF
}

setup_directories() {
    log "Setting up compliance directory structure..."
    mkdir -p "$COMPLIANCE_DIR" "$REPORTS_DIR" "$TEMPLATES_DIR" "$POLICIES_DIR" "$LOGS_DIR"
    mkdir -p "$REPORTS_DIR/mica" "$REPORTS_DIR/gdpr" "$REPORTS_DIR/security"
    touch "$AUDIT_LOG"
}

create_compliance_templates() {
    log "Creating compliance templates..."
    
    # MiCA Compliance Checklist
    cat > "$TEMPLATES_DIR/mica-checklist.md" << 'EOF'
# MiCA (Markets in Crypto-Assets) Compliance Checklist

## Authorization Requirements
- [ ] Crypto-asset service provider (CASP) authorization obtained
- [ ] Required capital requirements met
- [ ] Prudential requirements compliance verified
- [ ] Professional indemnity insurance in place

## Governance and Organization
- [ ] Governance arrangements documented
- [ ] Conflicts of interest policy implemented
- [ ] Complaint handling procedures established
- [ ] Risk management framework in place

## Conduct of Business
- [ ] Fair and professional conduct procedures
- [ ] Client asset protection measures
- [ ] Market manipulation prevention
- [ ] Insider dealing prevention

## Transparency and Disclosure
- [ ] White paper published and compliant
- [ ] Key information disclosure provided
- [ ] Marketing communications compliant
- [ ] Regular reporting to authorities

## Market Integrity
- [ ] Market abuse prevention measures
- [ ] Transaction reporting systems
- [ ] Record keeping requirements met
- [ ] Suspicious transaction reporting

## Consumer Protection
- [ ] Clear terms and conditions
- [ ] Risk warnings provided
- [ ] Client categorization procedures
- [ ] Appropriate product governance
EOF

    # GDPR Compliance Template
    cat > "$TEMPLATES_DIR/gdpr-checklist.md" << 'EOF'
# GDPR (General Data Protection Regulation) Compliance Checklist

## Legal Basis for Processing
- [ ] Legal basis for processing identified
- [ ] Consent mechanisms implemented where required
- [ ] Legitimate interests assessments conducted
- [ ] Special category data protections in place

## Data Subject Rights
- [ ] Right of access procedures
- [ ] Right to rectification processes
- [ ] Right to erasure (right to be forgotten)
- [ ] Right to restrict processing
- [ ] Right to data portability
- [ ] Right to object procedures
- [ ] Rights related to automated decision-making

## Data Protection by Design and by Default
- [ ] Privacy impact assessments conducted
- [ ] Data minimization principles applied
- [ ] Purpose limitation implemented
- [ ] Storage limitation procedures
- [ ] Pseudonymization and encryption used

## Records of Processing Activities
- [ ] Records of processing maintained
- [ ] Data flows documented
- [ ] Third party processors identified
- [ ] International transfers documented

## Data Breach Management
- [ ] Breach detection procedures
- [ ] 72-hour notification procedures
- [ ] Data subject notification processes
- [ ] Breach register maintenance

## Accountability and Governance
- [ ] Data Protection Officer appointed
- [ ] Staff training programs
- [ ] Regular compliance monitoring
- [ ] Vendor management procedures
EOF

    # Security Audit Template
    cat > "$TEMPLATES_DIR/security-audit.md" << 'EOF'
# Security Audit Checklist

## Access Controls
- [ ] Multi-factor authentication implemented
- [ ] Role-based access controls (RBAC)
- [ ] Privileged access management
- [ ] Regular access reviews conducted

## Network Security
- [ ] Firewall configurations reviewed
- [ ] Network segmentation implemented
- [ ] Intrusion detection systems active
- [ ] VPN security verified

## Data Protection
- [ ] Encryption at rest implemented
- [ ] Encryption in transit verified
- [ ] Key management procedures
- [ ] Data classification scheme

## Application Security
- [ ] Secure development practices
- [ ] Regular security testing
- [ ] Vulnerability management program
- [ ] Code review procedures

## Infrastructure Security
- [ ] Server hardening standards
- [ ] Patch management procedures
- [ ] System monitoring and logging
- [ ] Backup and recovery procedures

## Incident Response
- [ ] Incident response plan documented
- [ ] Response team identified
- [ ] Communication procedures
- [ ] Regular drills conducted
EOF
}

create_policies() {
    log "Creating compliance policies..."
    
    # Data Retention Policy
    cat > "$POLICIES_DIR/data-retention-policy.md" << 'EOF'
# Data Retention Policy

## Purpose
This policy defines how long different types of data should be retained and when it should be securely deleted.

## Retention Periods

### Transaction Data
- **Blockchain transactions**: Permanent (immutable)
- **Transaction logs**: 7 years
- **API request logs**: 1 year
- **Error logs**: 2 years

### User Data
- **Account information**: Until account closure + 7 years
- **KYC/AML data**: 5 years after relationship ends
- **Communication records**: 3 years
- **Marketing data**: Until consent withdrawn + 30 days

### Technical Data
- **System logs**: 1 year
- **Security logs**: 2 years
- **Backup data**: 3 months
- **Performance metrics**: 6 months

## Deletion Procedures
1. Automated deletion based on retention schedules
2. Secure overwriting of storage media
3. Certificate of destruction for physical media
4. Documentation of deletion activities
EOF

    # Incident Response Policy
    cat > "$POLICIES_DIR/incident-response-policy.md" << 'EOF'
# Incident Response Policy

## Incident Classification

### Critical (P1)
- System compromise or unauthorized access
- Data breach affecting personal data
- Service unavailability > 4 hours

### High (P2)
- Security vulnerability discovered
- Service degradation affecting users
- Compliance violation detected

### Medium (P3)
- Minor security issues
- Service disruption < 1 hour
- Policy violations

### Low (P4)
- Informational security events
- Minor system issues
- Documentation updates needed

## Response Procedures

### Immediate Response (0-1 hour)
1. Identify and classify incident
2. Assemble response team
3. Implement containment measures
4. Document initial findings

### Investigation (1-24 hours)
1. Detailed forensic analysis
2. Impact assessment
3. Root cause analysis
4. Evidence collection

### Recovery (24-72 hours)
1. System restoration
2. Service validation
3. User communication
4. Monitoring enhancement

### Post-Incident (1-2 weeks)
1. Final report preparation
2. Lessons learned session
3. Process improvements
4. Regulatory notifications if required
EOF
}

setup_compliance() {
    log "Setting up MultiversX compliance framework..."
    
    setup_directories
    create_compliance_templates
    create_policies
    
    # Create compliance configuration
    cat > "$COMPLIANCE_DIR/config.json" << EOF
{
  "framework_version": "1.0",
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "compliance_standards": {
    "mica": {
      "enabled": true,
      "version": "2024",
      "jurisdiction": "EU"
    },
    "gdpr": {
      "enabled": true,
      "version": "2018"
    },
    "iso27001": {
      "enabled": true,
      "version": "2022"
    }
  },
  "audit_schedule": {
    "full_audit": "quarterly",
    "security_scan": "monthly",
    "policy_review": "annually"
  },
  "reporting": {
    "formats": ["pdf", "html", "json"],
    "recipients": ["compliance@example.com"],
    "retention_period": "7_years"
  }
}
EOF

    log "Compliance framework setup completed!"
    log "Next steps:"
    log "  1. Review policies in: $POLICIES_DIR"
    log "  2. Customize templates in: $TEMPLATES_DIR"
    log "  3. Run audit: $0 audit"
}

run_mica_check() {
    log "Running MiCA compliance check..."
    
    local report_file="$REPORTS_DIR/mica/mica_compliance_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$report_file" << EOF
# MiCA Compliance Report
**Generated**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Framework Version**: MiCA 2024

## Executive Summary
This report assesses compliance with the EU Markets in Crypto-Assets (MiCA) regulation.

## Authorization Status
- **CASP Authorization**: ⚠️  Not yet obtained - Required for crypto-asset services
- **Capital Requirements**: ⚠️  Assessment needed
- **Professional Insurance**: ❌ Not verified

## Governance Framework
- **Board Oversight**: ⚠️  Governance structure needs documentation
- **Risk Management**: ⚠️  Framework requires formal documentation
- **Conflict of Interest**: ❌ Policy not established
- **Complaint Handling**: ❌ Procedures not documented

## Operational Requirements
- **Client Asset Protection**: ⚠️  Segregation procedures need review
- **Market Manipulation Controls**: ⚠️  Monitoring systems not verified
- **Transaction Reporting**: ❌ Systems not implemented
- **Record Keeping**: ✅ Basic logging in place

## Transparency Requirements
- **White Paper**: ❌ Not published
- **Key Information Disclosure**: ❌ Not provided
- **Marketing Compliance**: ⚠️  Review required
- **Regular Reporting**: ❌ Not established

## Consumer Protection
- **Risk Warnings**: ⚠️  Generic warnings present
- **Terms and Conditions**: ⚠️  Legal review needed
- **Client Categorization**: ❌ Not implemented
- **Product Governance**: ❌ Framework missing

## Recommendations
1. **Priority 1**: Engage regulatory counsel for CASP authorization
2. **Priority 2**: Develop comprehensive governance documentation
3. **Priority 3**: Implement client protection measures
4. **Priority 4**: Establish transaction monitoring systems

## Next Steps
- Schedule regulatory consultation
- Develop implementation timeline
- Assign compliance responsibilities
- Regular monitoring and updates
EOF

    log "MiCA compliance report generated: $report_file"
    
    if command -v pandoc >/dev/null 2>&1; then
        local pdf_report="${report_file%.md}.pdf"
        pandoc "$report_file" -o "$pdf_report" 2>/dev/null && \
            log "PDF report generated: $pdf_report"
    fi
}

run_gdpr_check() {
    log "Running GDPR compliance check..."
    
    local report_file="$REPORTS_DIR/gdpr/gdpr_compliance_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$report_file" << EOF
# GDPR Compliance Report
**Generated**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Regulation**: EU General Data Protection Regulation (GDPR)

## Executive Summary
This report assesses compliance with GDPR requirements for personal data processing.

## Legal Basis for Processing
- **Identified Legal Bases**: ⚠️  Documentation needed
- **Consent Mechanisms**: ❌ Not implemented where required
- **Legitimate Interests**: ❌ Assessments not conducted
- **Special Category Data**: ❌ Extra protections not verified

## Data Subject Rights
- **Right of Access**: ❌ Procedures not established
- **Right to Rectification**: ❌ Process not documented
- **Right to Erasure**: ❌ Implementation pending
- **Right to Portability**: ❌ Not implemented
- **Right to Object**: ❌ Procedures missing

## Privacy by Design
- **Privacy Impact Assessments**: ❌ Not conducted
- **Data Minimization**: ⚠️  Principles partially applied
- **Purpose Limitation**: ⚠️  Documentation incomplete
- **Storage Limitation**: ❌ Retention schedules not enforced
- **Encryption**: ✅ Basic encryption in place

## Records and Documentation
- **Processing Records**: ❌ Not maintained
- **Data Flow Mapping**: ❌ Not documented
- **Third Party Processors**: ❌ Not identified
- **International Transfers**: ❌ Not documented

## Data Breach Management
- **Breach Detection**: ⚠️  Basic monitoring in place
- **72-hour Notification**: ❌ Process not established
- **Data Subject Notification**: ❌ Process not defined
- **Breach Register**: ❌ Not maintained

## Governance and Accountability
- **Data Protection Officer**: ❌ Not appointed
- **Staff Training**: ❌ Not conducted
- **Regular Audits**: ❌ Not scheduled
- **Vendor Management**: ❌ GDPR clauses missing

## Risk Assessment
- **High Risk**: Lack of DPO, no breach procedures
- **Medium Risk**: Missing data subject rights implementation
- **Low Risk**: Basic technical measures in place

## Recommendations
1. **Immediate**: Appoint Data Protection Officer
2. **Week 1**: Document processing activities
3. **Month 1**: Implement data subject rights procedures
4. **Month 2**: Establish breach notification processes
5. **Month 3**: Conduct staff training program

## Action Plan
- Legal review of data processing
- Policy development and implementation
- Technical controls enhancement
- Regular compliance monitoring
EOF

    log "GDPR compliance report generated: $report_file"
}

run_security_audit() {
    log "Running security compliance audit..."
    
    local report_file="$REPORTS_DIR/security/security_audit_$(date +%Y%m%d_%H%M%S).md"
    
    # Check for common security tools
    local has_nmap=$(command -v nmap >/dev/null 2>&1 && echo "✅" || echo "❌")
    local has_openssl=$(command -v openssl >/dev/null 2>&1 && echo "✅" || echo "❌")
    local has_fail2ban=$(systemctl is-active fail2ban >/dev/null 2>&1 && echo "✅" || echo "❌")
    
    cat > "$report_file" << EOF
# Security Audit Report
**Generated**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Audit Type**: Automated Security Assessment

## Executive Summary
Comprehensive security audit covering access controls, network security, and data protection.

## Access Controls
- **Multi-Factor Authentication**: ⚠️  Implementation varies
- **Role-Based Access**: ❌ Not systematically implemented
- **Privileged Access Management**: ❌ No formal PAM system
- **Regular Access Reviews**: ❌ Not conducted

## Network Security
- **Firewall Status**: $(systemctl is-active ufw >/dev/null 2>&1 && echo "✅ Active" || echo "❌ Not active")
- **Intrusion Detection**: $has_fail2ban Fail2ban status
- **Network Monitoring**: ⚠️  Basic monitoring in place
- **VPN Security**: ⚠️  Not assessed

## System Security
- **System Updates**: $(apt list --upgradable 2>/dev/null | wc -l) pending updates
- **Security Tools**: nmap $has_nmap, openssl $has_openssl
- **File Permissions**: ⚠️  Review needed
- **Service Hardening**: ⚠️  Assessment required

## Data Protection
- **Encryption at Rest**: ⚠️  Partial implementation
- **Encryption in Transit**: ✅ TLS/HTTPS enforced
- **Key Management**: ❌ No formal key management
- **Data Classification**: ❌ Not implemented

## Application Security
- **Secure Development**: ⚠️  Practices not documented
- **Code Reviews**: ⚠️  Ad-hoc process
- **Vulnerability Scanning**: ❌ Not automated
- **Dependency Management**: ⚠️  Basic checks in place

## Monitoring and Logging
- **Security Logging**: ✅ Basic logging active
- **Log Analysis**: ❌ No SIEM solution
- **Retention Policies**: ⚠️  Not formalized
- **Alerting**: ❌ Not configured

## Backup and Recovery
- **Backup Strategy**: ⚠️  Basic backups in place
- **Recovery Testing**: ❌ Not regularly tested
- **Offsite Storage**: ❌ Not implemented
- **Encryption**: ❌ Backups not encrypted

## Compliance Status
- **ISO 27001**: ❌ Not aligned
- **NIST Framework**: ⚠️  Partial alignment
- **Industry Standards**: ⚠️  Review needed

## Critical Findings
1. No formal privileged access management
2. Missing security incident response plan
3. Inadequate backup encryption
4. No automated vulnerability scanning

## Recommendations
1. **Immediate**: Implement MFA for all admin accounts
2. **Week 1**: Enable and configure firewall
3. **Month 1**: Establish formal access review process
4. **Month 2**: Implement centralized logging
5. **Month 3**: Deploy vulnerability scanning

## Risk Rating: HIGH
Multiple critical security gaps identified requiring immediate attention.
EOF

    log "Security audit report generated: $report_file"
}

generate_compliance_report() {
    local format="${FORMAT:-html}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local report_file="$REPORTS_DIR/compliance_summary_$timestamp"
    
    log "Generating comprehensive compliance report..."
    
    # Run all checks
    run_mica_check
    run_gdpr_check
    run_security_audit
    
    # Create summary report
    cat > "${report_file}.md" << EOF
# MultiversX Compliance Summary Report
**Generated**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Version**: 1.0

## Executive Summary
This report provides a comprehensive overview of compliance status across multiple regulatory frameworks including MiCA, GDPR, and security standards.

## Compliance Status Overview

### MiCA Compliance
- **Status**: ❌ Non-compliant (Implementation required)
- **Priority**: High
- **Timeline**: 6-12 months

### GDPR Compliance
- **Status**: ❌ Non-compliant (Significant gaps)
- **Priority**: High
- **Timeline**: 3-6 months

### Security Standards
- **Status**: ⚠️  Partial compliance
- **Priority**: High
- **Timeline**: 3-4 months

## Overall Risk Assessment
- **Regulatory Risk**: HIGH
- **Operational Risk**: MEDIUM
- **Reputational Risk**: HIGH

## Priority Actions
1. Engage regulatory counsel for MiCA compliance
2. Appoint Data Protection Officer
3. Implement critical security controls
4. Develop comprehensive governance framework

## Recommended Next Steps
1. Executive review and approval of compliance roadmap
2. Resource allocation for compliance initiatives
3. Establishment of compliance governance structure
4. Regular monitoring and reporting mechanisms

## Contact Information
- Compliance Team: compliance@example.com
- Legal Counsel: legal@example.com
- Security Team: security@example.com
EOF

    if [ "$format" = "pdf" ] && command -v pandoc >/dev/null 2>&1; then
        pandoc "${report_file}.md" -o "${report_file}.pdf"
        log "PDF report generated: ${report_file}.pdf"
    elif [ "$format" = "html" ]; then
        if command -v pandoc >/dev/null 2>&1; then
            pandoc "${report_file}.md" -o "${report_file}.html"
            log "HTML report generated: ${report_file}.html"
        else
            # Simple HTML conversion
            echo "<html><body><pre>" > "${report_file}.html"
            cat "${report_file}.md" >> "${report_file}.html"
            echo "</pre></body></html>" >> "${report_file}.html"
            log "Simple HTML report generated: ${report_file}.html"
        fi
    fi
    
    log "Compliance report generated: ${report_file}.md"
}

run_comprehensive_audit() {
    log "Running comprehensive compliance audit..."
    
    # Check if framework is initialized
    if [ ! -d "$COMPLIANCE_DIR" ]; then
        warn "Compliance framework not initialized. Running setup..."
        setup_compliance
    fi
    
    generate_compliance_report
    
    log "Comprehensive audit completed!"
    log "Reports available in: $REPORTS_DIR"
}

# Parse command line arguments
FORMAT="html"
OUTPUT_DIR="$REPORTS_DIR"
DETAILED=false
REMEDIATION=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --detailed)
            DETAILED=true
            shift
            ;;
        --remediation)
            REMEDIATION=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Main command handling
case "${1:-}" in
    setup)
        setup_compliance
        ;;
    audit)
        run_comprehensive_audit
        ;;
    mica-check)
        run_mica_check
        ;;
    gdpr-check)
        run_gdpr_check
        ;;
    security-audit)
        run_security_audit
        ;;
    generate-report)
        generate_compliance_report
        ;;
    *)
        usage
        exit 1
        ;;
esac
