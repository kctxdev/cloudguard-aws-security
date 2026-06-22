import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("🚨 INTRUSÃO DETECTADA: Iniciando protocolo de análise!")
    
    try:
        # Extraindo dados do alerta do GuardDuty
        detalhes = event.get('detail', {})
        tipo_ameaca = detalhes.get('type', 'Desconhecido')
        severidade = detalhes.get('severity', 0)
        regiao = detalhes.get('region', 'Desconhecida')
        
        logger.warning(f"⚠️ Ameaça: {tipo_ameaca} | Severidade: {severidade}/10 | Região: {regiao}")
        
        # Se a severidade for alta (acima de 7), tomamos ação agressiva
        if float(severidade) >= 7.0:
            logger.error("🛑 Severidade ALTA! Acionando bloqueios automatizados (Isolamento de rede / Bloqueio de IAM).")
            # Aqui entraria o código boto3 para alterar o Security Group ou revogar credenciais IAM
        else:
            logger.info("👀 Severidade baixa/média. Apenas registrando para auditoria.")
            
    except Exception as e:
        logger.error(f"Erro ao processar o evento de segurança: {str(e)}")
        
    return {
        "statusCode": 200,
        "body": json.dumps("Análise de segurança concluída.")
    }