import React from 'react'
import { Router, Redirect, Switch, Route } from 'react-router-dom'
import { connect } from 'react-redux'

import history from 'adminPanelApp/routes/history'
import AuthenticatedRoute from 'adminPanelApp/routes/authenticatedRoute'
import LoginRoute from 'adminPanelApp/routes/loginRoute'
import LoginForm from 'omg-login-form'
import ForgetPasswordForm from 'omg-forgetPassword-form'
import CreateNewPasswordForm from 'omg-createNewPassword-form'
import InviteForm from 'omg-invite-form'
import AccountPage from 'omg-page-account'
import TokenPage from 'omg-page-token'
import TransactionPage from 'omg-page-transaction'
import WalletPage from 'omg-page-wallets'
import BlockchainWalletDetailPage from 'omg-page-blockchain-wallet-detail'
import BlockchainWalletsPage from 'omg-page-blockchain-wallets'
import UserSettingPage from 'omg-page-user-setting'
import ApiKeyPage from 'omg-page-api'
import ApiKeyDetailPage from 'omg-page-api-detail'
import KeyDetailAccountsPage from 'omg-page-api-detail-accounts'
import UserPage from 'omg-page-users'
import TokenDetailPage from 'omg-page-token-detail'
import WalletDetailPage from 'omg-page-wallet-detail'
import UserDetailPage from 'omg-page-user-detail'
import RequestConsumptionPage from 'omg-page-consumption'
import TransactionRequestPage from 'omg-page-transaction-request'
import TransactionExportPage from 'omg-page-transaction-export'
import ConfigurationPage from 'omg-page-configuration'
import AdminsPage from 'omg-page-admins'
import ActivityLogPage from 'omg-page-activity-log'
import AdminDetailPage from 'omg-page-admin-detail'
import NotFoundPage from 'omg-page-404'
import AccountLayout from 'omg-page-each-account/AccountLayout'
import VerifyEmail from 'omg-page-verify-email'
import ModalController from 'omg-modal/ModalController'
import Alert from 'omg-alert'
import { selectInternalEnabled } from 'omg-configuration/selector'

// prettier-ignore

const createRoute = ({ internalEnabled }) => (
  <Router basename='/admin' history={history}>
    <Switch>
      <Redirect from='/' to={'/accounts'} exact />
      <Redirect from='/accounts/:accountId' to='/accounts/:accountId/details' exact />
      <LoginRoute path='/login' exact component={LoginForm} />
      <LoginRoute path='/forget-password' exact component={ForgetPasswordForm} />
      <LoginRoute path='/create-new-password' exact component={CreateNewPasswordForm} />
      <LoginRoute path='/invite' exact component={InviteForm} />
      <Route path='/verify-email' exact component={VerifyEmail} />

      {/* MANAGE */}
      <AuthenticatedRoute path='/accounts' exact component={AccountPage} />
      <AuthenticatedRoute path='/tokens' exact component={TokenPage} />
      <AuthenticatedRoute path='/tokens/:viewTokenId/:state' exact component={TokenDetailPage} />
      <AuthenticatedRoute path='/tokens/:viewTokenId' exact component={TokenDetailPage} />
      <AuthenticatedRoute path='/wallets' exact component={internalEnabled? WalletPage : NotFoundPage} />
      <AuthenticatedRoute path='/blockchain_wallets' exact component={BlockchainWalletsPage} />
      <AuthenticatedRoute path='/blockchain_wallets/:address' component={BlockchainWalletDetailPage} />
      <AuthenticatedRoute path='/transaction' exact component={TransactionPage} />
      <AuthenticatedRoute path='/transaction/export' exact component={TransactionExportPage} />

      <AuthenticatedRoute path='/keys/:keyType/:keyId/assigned-accounts' exact component={KeyDetailAccountsPage} />
      <AuthenticatedRoute path='/keys/:keyType/:keyId' exact component={ApiKeyDetailPage} />
      <AuthenticatedRoute path='/keys/:keyType' exact component={ApiKeyPage} />
      <AuthenticatedRoute path='/keys' exact component={ApiKeyPage} />
      <AuthenticatedRoute path='/configuration' component={ConfigurationPage} />

      <AuthenticatedRoute path='/user_setting' exact component={UserSettingPage} />

      {/* SUB ACCOUNT PAGES */}
      <AuthenticatedRoute path='/accounts/:accountId/:type/:id' component={AccountLayout} />
      <AuthenticatedRoute path='/accounts/:accountId/:type' component={AccountLayout} />

      {/* OVERVIEW */}
      <AuthenticatedRoute path='/users/:userId/:type' exact component={() => <UserDetailPage withBreadCrumb />} />
      <AuthenticatedRoute path='/users/:userId' exact component={() => <UserDetailPage withBreadCrumb />} />

      <AuthenticatedRoute path='/consumptions' exact component={internalEnabled? RequestConsumptionPage : NotFoundPage} />
      <AuthenticatedRoute path='/requests' exact component={internalEnabled? TransactionRequestPage : NotFoundPage} />
      <AuthenticatedRoute path='/activity' exact component={ActivityLogPage} />
      <AuthenticatedRoute path='/users' exact component={UserPage} />
      <AuthenticatedRoute path='/admins' exact component={AdminsPage} />
      <AuthenticatedRoute path='/admins/:adminId' exact component={AdminDetailPage} />
      <AuthenticatedRoute path='/wallets/:walletAddress' exact component={internalEnabled? WalletDetailPage : NotFoundPage} />
      <AuthenticatedRoute path='/wallets/:walletAddress/:type' exact component={internalEnabled? WalletDetailPage : NotFoundPage} />

      {/* 404 PAGE */}
      <Route component={NotFoundPage} />
    </Switch>
    <Alert />
    <ModalController />
  </Router>
)

const mapStateToProps = (state) => ({
  internalEnabled: selectInternalEnabled()(state)
})

export default  connect(mapStateToProps, null)(createRoute)