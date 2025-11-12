import cron from 'node-cron';
import { supabase } from '../config/supabase';
import { openFinanceService } from '../services/openFinance.service';

/**
 * Scheduler para sincronização automática de conexões Open Finance
 *
 * Executa a cada 6 horas e sincroniza todas as conexões ativas
 */

let syncJobRunning = false;

/**
 * Sincroniza todas as conexões bancárias de todos os usuários
 */
async function syncAllConnections() {
  if (syncJobRunning) {
    console.log('⏳ Sync job already running, skipping...');
    return;
  }

  syncJobRunning = true;
  console.log('🔄 Starting automatic Open Finance sync...');

  try {
    // Buscar todas as conexões ativas (não em erro)
    const { data: connections, error } = await supabase
      .from('bank_connections')
      .select('id, user_id, status, last_sync_at')
      .in('status', ['UPDATED', 'UPDATING', 'OUTDATED'])
      .order('last_sync_at', { ascending: true, nullsFirst: true });

    if (error) {
      console.error('❌ Error fetching connections for sync:', error);
      return;
    }

    if (!connections || connections.length === 0) {
      console.log('ℹ️  No connections to sync');
      return;
    }

    console.log(`📊 Found ${connections.length} connections to sync`);

    let successCount = 0;
    let errorCount = 0;

    // Sincronizar cada conexão
    for (const connection of connections) {
      try {
        console.log(`   Syncing connection ${connection.id} for user ${connection.user_id}...`);

        // Log de início
        await supabase.from('sync_logs').insert({
          connection_id: connection.id,
          sync_type: 'automatic',
          status: 'started',
        });

        // Executar sincronização
        const result = await openFinanceService.syncBankConnection(
          connection.user_id,
          connection.id
        );

        // Log de sucesso
        await supabase.from('sync_logs').insert({
          connection_id: connection.id,
          sync_type: 'automatic',
          status: 'success',
          accounts_synced: result.accounts,
          transactions_synced: result.transactions,
          completed_at: new Date().toISOString(),
        });

        console.log(
          `   ✅ Synced ${result.accounts} accounts and ${result.transactions} transactions`
        );
        successCount++;

        // Wait a bit between syncs to avoid rate limiting
        await new Promise((resolve) => setTimeout(resolve, 2000));
      } catch (error) {
        console.error(`   ❌ Error syncing connection ${connection.id}:`, error);

        // Log de erro
        await supabase.from('sync_logs').insert({
          connection_id: connection.id,
          sync_type: 'automatic',
          status: 'error',
          error_message: error instanceof Error ? error.message : 'Unknown error',
          completed_at: new Date().toISOString(),
        });

        errorCount++;
      }
    }

    console.log(
      `✅ Automatic sync completed: ${successCount} successful, ${errorCount} errors`
    );
  } catch (error) {
    console.error('❌ Error in automatic sync job:', error);
  } finally {
    syncJobRunning = false;
  }
}

/**
 * Sincroniza conexões desatualizadas (que não foram sincronizadas nas últimas 12 horas)
 */
async function syncOutdatedConnections() {
  console.log('🔍 Checking for outdated connections...');

  try {
    const twelveHoursAgo = new Date();
    twelveHoursAgo.setHours(twelveHoursAgo.getHours() - 12);

    const { data: connections, error } = await supabase
      .from('bank_connections')
      .select('id, user_id')
      .eq('status', 'UPDATED')
      .lt('last_sync_at', twelveHoursAgo.toISOString())
      .limit(10); // Limit to avoid overwhelming the system

    if (error) {
      console.error('❌ Error fetching outdated connections:', error);
      return;
    }

    if (!connections || connections.length === 0) {
      console.log('ℹ️  No outdated connections found');
      return;
    }

    console.log(`📊 Found ${connections.length} outdated connections`);

    for (const connection of connections) {
      try {
        await openFinanceService.syncBankConnection(connection.user_id, connection.id);
        console.log(`   ✅ Synced outdated connection ${connection.id}`);

        // Wait between syncs
        await new Promise((resolve) => setTimeout(resolve, 3000));
      } catch (error) {
        console.error(`   ❌ Error syncing outdated connection ${connection.id}:`, error);
      }
    }
  } catch (error) {
    console.error('❌ Error checking outdated connections:', error);
  }
}

/**
 * Inicializa os schedulers de sincronização
 */
export function initOpenFinanceSchedulers() {
  console.log('📅 Initializing Open Finance schedulers...');

  // Sincronização completa a cada 6 horas
  cron.schedule('0 */6 * * *', async () => {
    console.log('⏰ Running scheduled Open Finance sync (every 6 hours)');
    await syncAllConnections();
  });

  // Verificar conexões desatualizadas a cada hora
  cron.schedule('0 * * * *', async () => {
    console.log('⏰ Checking for outdated connections (hourly)');
    await syncOutdatedConnections();
  });

  // Sincronização diária completa às 3h da manhã (horário de menor uso)
  cron.schedule('0 3 * * *', async () => {
    console.log('⏰ Running daily complete sync (3 AM)');
    await syncAllConnections();
  });

  console.log('✅ Open Finance schedulers initialized');
  console.log('   • Full sync: Every 6 hours');
  console.log('   • Outdated check: Every hour');
  console.log('   • Daily complete sync: 3 AM');
}

// Export para uso manual
export { syncAllConnections, syncOutdatedConnections };
